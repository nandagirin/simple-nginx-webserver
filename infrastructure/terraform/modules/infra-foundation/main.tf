# ====================================================================================
# Terraform Configuration Summary
#
# This file provisions the following AWS infrastructure components using Terraform:
#
# 1. VPC: A custom Virtual Private Cloud with public, private (service), and intra (data) subnets
# 2. NAT Gateway or FCK NAT: For outbound internet access from private subnets
# 3. VPC Endpoints: Optionally provisions a Gateway Endpoint for S3
# 4. ECS Cluster: To deploy ECS workloads
#
# Each module is parameterized using variables for flexibility and reuse.
# ====================================================================================

# ----------------------------------------------------------------------------
# VPC Module - Creates the core VPC infrastructure including subnets and NAT
# ----------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  public_subnets  = var.vpc_public_subnets         # Subnets for public-facing resources
  private_subnets = var.vpc_service_subnets        # Subnets for ECS services
  intra_subnets   = var.vpc_data_subnets           # Subnets for internal resources (e.g., databases)

  # Enable NAT Gateway if egress is needed and NAT is selected as the method
  enable_nat_gateway     = var.vpc_enable_public_egress_traffic && var.vpc_public_egress_traffic_using_nat_gw_or_fck_nat == "nat" ? true : false
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

  tags = var.vpc_tags
}

# -----------------------------------------------------------------------------
# VPC Endpoints Module - Creates interface or gateway endpoints like S3
# -----------------------------------------------------------------------------
module "vpc_endpoints" {
  count = var.vpc_endpoint != null ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  # Include all subnets for endpoint attachment
  subnet_ids = concat(
    module.vpc.public_subnets,
    module.vpc.private_subnets,
    module.vpc.intra_subnets,
  )

  # Use default security group
  security_group_ids = [module.vpc.default_security_group_id]

  # Configure Gateway VPC Endpoint for S3 if requested
  endpoints = {
    s3 = lookup(var.vpc_endpoint, "s3", false) == true ? {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = concat(
        module.vpc.public_route_table_ids,
        module.vpc.private_route_table_ids,
        module.vpc.intra_route_table_ids,
      )
      tags = { Name = "${module.vpc.name}-s3-vpc-endpoint" }
    } : null
  }

  tags = var.vpc_tags
}

# -----------------------------------------------------------------------------
# FCK NAT Module - Deploys custom NAT instance if selected instead of NAT Gateway
# -----------------------------------------------------------------------------
module "fck_nat" {
  count = var.vpc_enable_public_egress_traffic && var.vpc_public_egress_traffic_using_nat_gw_or_fck_nat == "fck_nat" ? 1 : 0

  source = "git::https://github.com/RaJiska/terraform-aws-fck-nat.git?ref=v1.3.0"

  name          = var.vpc_fck_nat_instance_name
  instance_type = var.vpc_fck_nat_instance_type
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]  # Place NAT instance in the first public subnet

  update_route_tables = true
  route_tables_ids = { for index, rtb in module.vpc.private_route_table_ids :  index => rtb }
}

# -----------------------------------------------------------------------------
# ECS Cluster Module - Deploys an ECS Cluster
# -----------------------------------------------------------------------------
module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.0"

  cluster_name = var.ecs_cluster_name

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = var.ecs_fargate_default_capacity_provider_strategy
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = var.ecs_fargate_spot_default_capacity_provider_strategy
      }
    }
  }

  tags = var.ecs_cluster_tags
}
