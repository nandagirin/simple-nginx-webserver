variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the ECS service into"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = null
}

variable "ecs_task_desired_count" {
  description = "Number of ECS task instances to run"
  type        = number
  default     = 1
}

variable "ecs_enable_cloudwatch_logging" {
  description = "Whether to enable CloudWatch logging for ECS containers"
  type        = bool
  default     = false
}

variable "ecs_cloudwatch_logging_retention_period_in_days" {
  description = "Retention period for CloudWatch log groups (in days)"
  type        = number
  default     = 7
}

variable "ecs_cpu" {
  description = "Amount of CPU to allocate for the ECS task (in CPU units)"
  type        = number
  default     = 512
}

variable "ecs_memory" {
  description = "Amount of memory to allocate for the ECS task (in MiB)"
  type        = number
  default     = 1024
}

variable "ecs_container_definitions" {
  description = "List of container definitions for the ECS task"
  type        = any
}

variable "ecs_additional_task_policy" {
  description = "Additional IAM policy to attach to the ECS task role"
  type        = any
  default     = null
}

variable "ecs_volumes" {
  description = "List of volumes to be used by the ECS task"
  type        = list(any)
  default     = []
}

variable "ecs_vpc_subnets_ids" {
  description = "List of subnet IDs for ECS task networking"
  type        = list(string)
}

variable "ecs_ingress_security_group_rules" {
  description = "Ingress security group rules for the ECS service"
  type        = list(any)
  default     = []
}

variable "ecs_egress_security_group_rules" {
  description = "Egress security group rules for the ECS service"
  type        = list(any)
  default     = []
}

variable "ecs_deployment_controller" {
  description = "Type of deployment controller to use (e.g., ECS, CODE_DEPLOY)"
  type        = string
  default     = "ECS"
}

variable "alb_enable" {
  description = "Whether to create an Application Load Balancer for the service"
  type        = bool
  default     = false
}

variable "alb_vpc_subnets_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
  default     = null
}

variable "alb_ecs_container_name" {
  description = "Name of the ECS container to register with the ALB target group"
  type        = string
  default     = null
}

variable "alb_ecs_service_port" {
  description = "Port on the ECS container for ALB to forward traffic to"
  type        = number
  default     = null
}

variable "alb_enable_https_listener" {
  description = "Whether to enable an HTTPS listener on the ALB"
  type        = bool
  default     = false
}

variable "alb_certificate_arn" {
  description = "ARN of the ACM certificate to use for HTTPS listener"
  type        = string
  default     = null
}

variable "alb_register_dns_route53" {
  description = "Whether to register ALB DNS in Route53"
  type        = string
  default     = "false"
}

variable "alb_route53_zone_id" {
  description = "Route53 hosted zone ID for DNS registration"
  type        = string
  default     = null
}

variable "alb_route53_domain_name" {
  description = "Domain name to associate with the ALB in Route53"
  type        = string
  default     = null
}

variable "codedeploy_config_name" {
  description = "Name of the CodeDeploy deployment configuration"
  type        = string
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "codedeploy_enable_auto_rollback_on_deployment_failure" {
  description = "Whether to enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

variable "codedeploy_deployment_type" {
  description = "Type of CodeDeploy deployment (e.g., BLUE_GREEN)"
  type        = string
  default     = "BLUE_GREEN"
}

variable "codedeploy_deployment_option" {
  description = "Deployment option for CodeDeploy (e.g., WITH_TRAFFIC_CONTROL)"
  type        = string
  default     = "WITH_TRAFFIC_CONTROL"
}

variable "codedeploy_blue_green_deployment_ready_action" {
  description = "Action to take when the new task set is ready (e.g., CONTINUE_DEPLOYMENT)"
  type        = string
  default     = "CONTINUE_DEPLOYMENT"
}

variable "codedeploy_blue_green_deployment_ready_wait_time_in_minutes" {
  description = "Wait time in minutes before continuing blue/green deployment"
  type        = number
  default     = 5
}

variable "codedeploy_terminate_blue_instances_on_deployment_success_action" {
  description = "Action to take on the old task set after deployment success"
  type        = string
  default     = "TERMINATE"
}

variable "codedeploy_terminate_blue_instances_on_deployment_success_wait_time_in_minutes" {
  description = "Wait time before terminating old task set (in minutes)"
  type        = number
  default     = 1
}

variable "ssm_configs" {
  description = "List of SSM parameters used in the ECS task"
  type        = list(map(any))
  default     = null
}
