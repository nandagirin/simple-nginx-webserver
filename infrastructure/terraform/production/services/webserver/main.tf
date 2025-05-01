locals {
  environment            = "prod"
  service_name           = "webserver-${local.environment}"
  service_port           = 80
  ssm_config_path_prefix = "/ecs/${local.environment}/${local.service_name}"
  default_html_s3_path   = "v0/index.html"
}

# S3 Bucket
module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${local.service_name}-s3"

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowOrgAccessOnly"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${local.service_name}-s3",
          "arn:aws:s3:::${local.service_name}-s3/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-k6jr2nosre"
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::${local.service_name}-s3/*"
      },
    ]
  })
}

module "service" {
  source = "../../../modules/ecs-service"

  service_name        = local.service_name
  vpc_id              = data.terraform_remote_state.infra_foundation.outputs.vpc_id
  ecs_cluster_arn     = data.terraform_remote_state.infra_foundation.outputs.ecs_cluster_arn
  ecs_cluster_name    = data.terraform_remote_state.infra_foundation.outputs.ecs_cluster_name
  ecs_vpc_subnets_ids = data.terraform_remote_state.infra_foundation.outputs.vpc_service_subnets_ids

  ecs_cpu    = 512
  ecs_memory = 1024

  ecs_enable_cloudwatch_logging                   = true
  ecs_cloudwatch_logging_retention_period_in_days = 1

  ecs_deployment_controller = "CODE_DEPLOY"
  ecs_ingress_security_group_rules = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
  ecs_egress_security_group_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  ecs_task_desired_count = 1

  ecs_additional_task_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "${module.s3.s3_bucket_arn}/*"
      },
    ]
  })

  ecs_container_definitions = [
    {
      name      = local.service_name
      image     = "public.ecr.aws/nginx/nginx:1.28-alpine3.21-slim"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          name          = "http"
          containerPort = local.service_port
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "wget -q --spider http://localhost/ || exit 1"],
        interval    = 30,
        timeout     = 5,
        retries     = 3,
        startPeriod = 30
      }
      dependsOn = [{
        containerName = "html-fetcher"
        condition     = "SUCCESS"
      }]
      readonlyRootFilesystem = false
      mountPoints = [{
        sourceVolume  = "html"
        containerPath = "/usr/share/nginx/html"
        readOnly      = false
      }]
    },
    {
      name       = "html-fetcher"
      image      = "public.ecr.aws/amazonlinux/amazonlinux:2"
      cpu        = 64
      memory     = 128
      essential  = false
      entryPoint = ["/bin/sh", "-c"]
      command = [
        "yum install -y aws-cli && aws s3 cp s3://${module.s3.s3_bucket_id}/$S3HTMLPath /html/index.html"
      ]
      secrets = [
        {
          name      = "S3HTMLPath"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_config_path_prefix}/s3-html-path"
        }
      ]
      readonlyRootFilesystem = false
      mountPoints = [{
        sourceVolume  = "html"
        containerPath = "/html"
        readOnly      = false
      }]
    }
  ]

  ecs_volumes = [{
    name = "html"
  }]

  alb_enable                = true
  alb_vpc_subnets_ids       = data.terraform_remote_state.infra_foundation.outputs.vpc_public_subnets_ids
  alb_ecs_container_name    = local.service_name
  alb_ecs_service_port      = 80
  alb_enable_https_listener = true
  alb_certificate_arn       = data.terraform_remote_state.global.outputs.grnnd_online_acm_certificate_arn
  alb_register_dns_route53  = true
  alb_route53_zone_id       = data.terraform_remote_state.global.outputs.grnnd_online_route53_zone_id

  codedeploy_deployment_option = "WITH_TRAFFIC_CONTROL"
  codedeploy_deployment_type   = "BLUE_GREEN"

  ssm_configs = [
    {
      name  = "${local.ssm_config_path_prefix}/s3-html-path"
      value = local.default_html_s3_path
    }
  ]
}