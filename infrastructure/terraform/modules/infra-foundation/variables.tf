# VPC
variable "vpc_name" {
  type        = string
  description = "Name for the VPC resource"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., '10.0.0.0/16')"
}

variable "vpc_azs" {
  type        = list(string)
  description = "List of availability zones to use in the VPC"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}

variable "vpc_service_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for service (application) subnets"
}

variable "vpc_data_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for data (e.g., database) subnets"
}

variable "vpc_enable_public_egress_traffic" {
  type        = bool
  default     = true
  description = "Whether to enable public egress traffic from the VPC"
}

variable "vpc_public_egress_traffic_using_nat_gw_or_fck_nat" {
  type        = string
  default     = "nat"
  description = "Method for public egress: 'nat' for NAT Gateway or 'fck_nat' for custom NAT instance"
}

variable "vpc_single_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to deploy a single NAT Gateway for all AZs"
}

variable "vpc_one_nat_gateway_per_az" {
  type        = bool
  default     = false
  description = "Whether to deploy one NAT Gateway per AZ (high availability)"
}

variable "vpc_fck_nat_instance_name" {
  type        = string
  default     = "nat-instance"
  description = "Name of the FCK NAT instance if using a custom NAT setup"
}

variable "vpc_fck_nat_instance_type" {
  type        = string
  default     = "t4g.micro"
  description = "Name of the FCK NAT instance if using a custom NAT setup"
}

variable "vpc_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all VPC resources"
}

variable "vpc_endpoint" {
  type = object({
    s3 = optional(bool)
  })
  default     = null
  description = "Configuration for VPC endpoints (e.g., enable S3 endpoint)"
}

# ECS
variable "ecs_cluster_name" {
  type        = string
  description = "Name for the ECS cluster"
}

variable "ecs_fargate_default_capacity_provider_strategy" {
  type        = number
  default     = 50
  description = "Percentage of tasks to run using Fargate standard capacity"
}

variable "ecs_fargate_spot_default_capacity_provider_strategy" {
  type        = number
  default     = 50
  description = "Percentage of tasks to run using Fargate Spot for cost savings"
}

variable "ecs_cluster_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the ECS cluster"
}
