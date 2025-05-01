output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the created VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "The CIDR block associated with the VPC"
}

output "vpc_public_subnets_ids" {
  value       = module.vpc.public_subnets
  description = "List of public subnet IDs created in the VPC"
}

output "vpc_public_subnets_cidr_blocks" {
  value       = module.vpc.public_subnets_cidr_blocks
  description = "List of CIDR blocks for the public subnets"
}

output "vpc_service_subnets_ids" {
  value       = module.vpc.private_subnets
  description = "List of private (service) subnet IDs"
}

output "vpc_service_subnets_cidr_blocks" {
  value       = module.vpc.private_subnets_cidr_blocks
  description = "List of CIDR blocks for the private (service) subnets"
}

output "vpc_data_subnets_ids" {
  value       = module.vpc.intra_subnets
  description = "List of intra (data) subnet IDs"
}

output "vpc_data_subnets_cidr_blocks" {
  value       = module.vpc.intra_subnets_cidr_blocks
  description = "List of CIDR blocks for the intra (data) subnets"
}

output "ecs_cluster_arn" {
  value       = module.ecs_cluster.arn
  description = "ARN of the ECS cluster"
}

output "ecs_cluster_name" {
  value       = module.ecs_cluster.name
  description = "Name of the ECS cluster"
}
