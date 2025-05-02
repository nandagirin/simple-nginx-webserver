# ====================================================================================
# Terraform Configuration Summary
#
# This file provisions the following AWS infrastructure components using Terraform:
#
# 1. ALB (Application Load Balancer):
#    - Routes incoming HTTP/HTTPS traffic to ECS containers.
#    - Supports blue/green deployments via target groups.
#    - Optionally registers a DNS record in Route 53.
#
# 2. ECS Service:
#    - Deploys containerized applications on Fargate.
#    - Includes task definition, IAM roles, networking, and logging setup.
#    - Integrated with ALB for traffic routing.
#
# 3. CodeDeploy:
#    - Manages ECS blue/green deployment strategy.
#    - Configures rollback and lifecycle behaviors.
#    - Uses a dedicated IAM role for deployment permissions.
#
# 4. SSM (AWS Systems Manager):
#    - Stores parameter configurations such as environment variables.
#    - Accessible from ECS tasks via IAM permissions.
#
# Each module is parameterized using variables for flexibility and reuse.
# ====================================================================================

# ----------------------------------------------------------------------------
# ALB Module - Creates AWS ALB as entrypoint to the ECS service
# ----------------------------------------------------------------------------
locals {
  alb_ingress_security_group_rules = var.alb_enable_https_listener ? [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ] : [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "alb_sg" {
  count = var.alb_enable ? 1 : 0

  name   = "${var.service_name}-alb-sg"
  vpc_id = data.aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = toset(local.alb_ingress_security_group_rules)
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = lookup(ingress.value, "protocol", "tcp")
      security_groups = lookup(ingress.value, "security_groups", null)
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      description     = lookup(ingress.value, "description", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_lb" "alb" {
  count = var.alb_enable ? 1 : 0

  name               = "${var.service_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.0.id]
  subnets            = var.alb_vpc_subnets_ids
}

resource "aws_lb_target_group" "blue" {
  depends_on = [aws_lb.alb]
  count      = var.alb_enable ? 1 : 0

  name        = "${var.service_name}-alb-tg-blue"
  port        = var.alb_ecs_service_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
}

resource "aws_lb_target_group" "green" {
  depends_on = [aws_lb.alb]
  count      = var.alb_enable ? 1 : 0

  name        = "${var.service_name}-alb-tg-green"
  port        = var.alb_ecs_service_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.vpc.id
}

resource "aws_lb_listener" "http_listener" {
  count = var.alb_enable && !var.alb_enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.alb.0.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.0.arn
  }
}

resource "aws_lb_listener" "http_to_https_redirect_listener" {
  count = var.alb_enable && var.alb_enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.alb.0.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  count = var.alb_enable && var.alb_enable_https_listener ? 1 : 0

  load_balancer_arn = aws_lb.alb.0.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.0.arn
  }

  lifecycle {
    ignore_changes = [default_action.0.target_group_arn]
  }
}

data "aws_route53_zone" "zone" {
  count   = var.alb_enable && var.alb_register_dns_route53 ? 1 : 0
  zone_id = var.alb_route53_zone_id
}

resource "aws_route53_record" "alb_record" {
  count = var.alb_enable && var.alb_register_dns_route53 ? 1 : 0

  allow_overwrite = true
  name            = var.alb_route53_domain_name != null ? var.alb_route53_domain_name : "${var.service_name}.${data.aws_route53_zone.zone.0.name}"
  records         = [aws_lb.alb.0.dns_name]
  ttl             = 300
  type            = "CNAME"
  zone_id         = data.aws_route53_zone.zone.0.zone_id
}

# ----------------------------------------------------------------------------
# ECS Module - Creates ECS Service and Task Definition as well as ALB attachment
# ----------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_role" {
  name = "ECSTaskRole-${var.service_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_role_iam_policy" {
  name = "ECSTaskPolicy-${var.service_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat([
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters"
        ],
        Resource = "*"
      },
      ], var.ecs_enable_cloudwatch_logging ? [{
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
    }] : [])
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_iam_policy.arn
}

resource "aws_iam_policy" "ecs_task_role_additional_iam_policy" {
  count  = var.ecs_additional_task_policy != null ? 1 : 0
  name   = "ECSTaskPolicyAdditional-${var.service_name}"
  policy = var.ecs_additional_task_policy
}

resource "aws_iam_role_policy_attachment" "ecs_task_additional_policy_attachment" {
  count      = var.ecs_additional_task_policy != null ? 1 : 0
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_additional_iam_policy.0.arn
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  count             = var.ecs_enable_cloudwatch_logging ? 1 : 0
  name              = "/ecs/${var.service_name}"
  retention_in_days = var.ecs_cloudwatch_logging_retention_period_in_days
}

resource "aws_ecs_task_definition" "service" {
  depends_on = [aws_ssm_parameter.ssm_configs]

  family                   = var.service_name
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([
    for container in var.ecs_container_definitions : {
      name                   = container.name
      image                  = container.image
      cpu                    = lookup(container, "cpu", null)
      memory                 = lookup(container, "memory", null)
      essential              = lookup(container, "essential", null)
      entryPoint             = lookup(container, "entryPoint", null)
      command                = lookup(container, "command", null)
      secrets                = lookup(container, "secrets", null)
      portMappings           = lookup(container, "portMappings", null)
      healthCheck            = lookup(container, "healthCheck", null)
      dependsOn              = lookup(container, "dependsOn", null)
      readonlyRootFilesystem = lookup(container, "readonlyRootFilesystem", null)
      mountPoints            = lookup(container, "mountPoints", null)
      logConfiguration = var.ecs_enable_cloudwatch_logging ? {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.0.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = container.name
        }
      } : null
    }
  ])

  dynamic "volume" {
    for_each = var.ecs_volumes
    content {
      name = volume.value.name
    }
  }
}

resource "aws_security_group" "service" {
  name   = "${var.service_name}-ecs"
  vpc_id = data.aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = toset(var.ecs_ingress_security_group_rules)
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = lookup(ingress.value, "protocol", "tcp")
      security_groups = lookup(ingress.value, "security_groups", null)
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      description     = lookup(ingress.value, "description", null)
    }
  }

  dynamic "egress" {
    for_each = toset(var.ecs_egress_security_group_rules)
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = lookup(egress.value, "protocol", "tcp")
      security_groups = lookup(egress.value, "security_groups", null)
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      description     = lookup(egress.value, "description", null)
    }
  }
}

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = var.ecs_task_desired_count

  launch_type    = "FARGATE"
  propagate_tags = "SERVICE"

  network_configuration {
    subnets          = var.ecs_vpc_subnets_ids
    assign_public_ip = false
    security_groups  = [aws_security_group.service.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.0.arn
    container_name   = var.alb_ecs_container_name != null ? var.alb_ecs_container_name : var.service_name
    container_port   = var.alb_ecs_service_port
  }

  deployment_controller {
    type = var.ecs_deployment_controller
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
    ]
  }
}

# ----------------------------------------------------------------------------
# Codedeploy Module - Creates AWS Codedeploy application and deployment
# ----------------------------------------------------------------------------
resource "aws_iam_role" "codedeploy_role" {
  count = var.ecs_deployment_controller == "CODE_DEPLOY" ? 1 : 0

  name = "CodeDeployRole-${aws_ecs_service.service.name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role" {
  count      = var.ecs_deployment_controller == "CODE_DEPLOY" ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.codedeploy_role.0.name
}

resource "aws_codedeploy_app" "ecs_service" {
  count            = var.ecs_deployment_controller == "CODE_DEPLOY" ? 1 : 0
  compute_platform = "ECS"
  name             = aws_ecs_service.service.name
}

resource "aws_codedeploy_deployment_group" "codedeploy_ecs_service" {
  count      = var.ecs_deployment_controller == "CODE_DEPLOY" ? 1 : 0
  depends_on = [aws_iam_role_policy_attachment.codedeploy_role]

  app_name               = aws_codedeploy_app.ecs_service.0.name
  deployment_config_name = var.codedeploy_config_name
  deployment_group_name  = aws_codedeploy_app.ecs_service.0.name
  service_role_arn       = aws_iam_role.codedeploy_role.0.arn

  auto_rollback_configuration {
    enabled = var.codedeploy_enable_auto_rollback_on_deployment_failure
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = var.codedeploy_blue_green_deployment_ready_action
      wait_time_in_minutes = var.codedeploy_blue_green_deployment_ready_action == "STOP_DEPLOYMENT" ? var.codedeploy_blue_green_deployment_ready_wait_time_in_minutes : null
    }

    terminate_blue_instances_on_deployment_success {
      action                           = var.codedeploy_terminate_blue_instances_on_deployment_success_action
      termination_wait_time_in_minutes = var.codedeploy_terminate_blue_instances_on_deployment_success_action == "TERMINATE" ? var.codedeploy_terminate_blue_instances_on_deployment_success_wait_time_in_minutes : null
    }
  }

  deployment_style {
    deployment_option = var.codedeploy_deployment_option
    deployment_type   = var.codedeploy_deployment_type
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = aws_ecs_service.service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.alb_enable_https_listener ? [aws_lb_listener.https_listener.0.arn] : [aws_lb_listener.http_listener.0.arn]
      }
      target_group {
        name = aws_lb_target_group.blue.0.name
      }
      target_group {
        name = aws_lb_target_group.green.0.name
      }
    }
  }
}

# ----------------------------------------------------------------------------
# SSM Module - Creates AWS SSM parameters to be used by ECS service
# ----------------------------------------------------------------------------
resource "aws_ssm_parameter" "ssm_configs" {
  for_each = {
    for config in var.ssm_configs : config.name => config
  }

  name      = each.value.name
  value     = each.value.value
  type      = lookup(each.value, "type", "String")
  overwrite = lookup(each.value, "overwrite", true)

  lifecycle {
    ignore_changes = [ name, value ]
  }
}
