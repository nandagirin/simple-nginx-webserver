locals {
  vpc_cidr    = "10.10.0.0/16"
  environment = "staging"
}

module "infra_foundation" {
  source = "../../modules/infra-foundation"

  vpc_name = "vpc-${local.environment}"
  vpc_azs  = ["ap-southeast-1a", "ap-southeast-1b"]

  vpc_cidr = local.vpc_cidr
  vpc_public_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 0),
    cidrsubnet(local.vpc_cidr, 8, 1),
  ]

  vpc_service_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 2),
    cidrsubnet(local.vpc_cidr, 8, 3),
  ]

  vpc_data_subnets = [
    cidrsubnet(local.vpc_cidr, 8, 4),
    cidrsubnet(local.vpc_cidr, 8, 5),
  ]

  vpc_endpoint = {
    s3 = true
  }

  vpc_tags = {
    Terraform   = "true"
    Environment = local.environment
    Context     = "vpc"
  }

  vpc_public_egress_traffic_using_nat_gw_or_fck_nat = "fck_nat"

  ecs_cluster_name                                    = "ecs-${local.environment}"
  ecs_fargate_default_capacity_provider_strategy      = 10
  ecs_fargate_spot_default_capacity_provider_strategy = 90
  ecs_cluster_tags = {
    Terraform   = "true"
    Environment = local.environment
    Context     = "ecs"
  }
}
