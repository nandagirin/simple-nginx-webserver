output "vpc_id" {
  value = module.infra_foundation.vpc_id
}

output "vpc_cidr_block" {
  value = module.infra_foundation.vpc_cidr_block
}

output "vpc_public_subnets_ids" {
  value = module.infra_foundation.vpc_public_subnets_ids
}

output "vpc_public_subnets_cidr_blocks" {
  value = module.infra_foundation.vpc_public_subnets_cidr_blocks
}

output "vpc_service_subnets_ids" {
  value = module.infra_foundation.vpc_service_subnets_ids
}

output "vpc_service_subnets_cidr_blocks" {
  value = module.infra_foundation.vpc_service_subnets_cidr_blocks
}

output "vpc_data_subnets_ids" {
  value = module.infra_foundation.vpc_data_subnets_ids
}

output "vpc_data_subnets_cidr_blocks" {
  value = module.infra_foundation.vpc_data_subnets_cidr_blocks
}

output "ecs_cluster_arn" {
  value = module.infra_foundation.ecs_cluster_arn
}

output "ecs_cluster_name" {
  value = module.infra_foundation.ecs_cluster_name
}
