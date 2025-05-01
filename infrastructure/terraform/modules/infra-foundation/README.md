## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | terraform-aws-modules/ecs/aws//modules/cluster | ~> 5.0 |
| <a name="module_fck_nat"></a> [fck\_nat](#module\_fck\_nat) | git::https://github.com/RaJiska/terraform-aws-fck-nat.git | v1.3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name for the ECS cluster | `string` | n/a | yes |
| <a name="input_ecs_cluster_tags"></a> [ecs\_cluster\_tags](#input\_ecs\_cluster\_tags) | Tags to apply to the ECS cluster | `map(string)` | `{}` | no |
| <a name="input_ecs_fargate_default_capacity_provider_strategy"></a> [ecs\_fargate\_default\_capacity\_provider\_strategy](#input\_ecs\_fargate\_default\_capacity\_provider\_strategy) | Percentage of tasks to run using Fargate standard capacity | `number` | `50` | no |
| <a name="input_ecs_fargate_spot_default_capacity_provider_strategy"></a> [ecs\_fargate\_spot\_default\_capacity\_provider\_strategy](#input\_ecs\_fargate\_spot\_default\_capacity\_provider\_strategy) | Percentage of tasks to run using Fargate Spot for cost savings | `number` | `50` | no |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | List of availability zones to use in the VPC | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC (e.g., '10.0.0.0/16') | `string` | n/a | yes |
| <a name="input_vpc_data_subnets"></a> [vpc\_data\_subnets](#input\_vpc\_data\_subnets) | List of CIDR blocks for data (e.g., database) subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_enable_public_egress_traffic"></a> [vpc\_enable\_public\_egress\_traffic](#input\_vpc\_enable\_public\_egress\_traffic) | Whether to enable public egress traffic from the VPC | `bool` | `true` | no |
| <a name="input_vpc_endpoint"></a> [vpc\_endpoint](#input\_vpc\_endpoint) | Configuration for VPC endpoints (e.g., enable S3 endpoint) | <pre>object({<br>    s3 = optional(bool)<br>  })</pre> | `null` | no |
| <a name="input_vpc_fck_nat_instance_name"></a> [vpc\_fck\_nat\_instance\_name](#input\_vpc\_fck\_nat\_instance\_name) | Name of the FCK NAT instance if using a custom NAT setup | `string` | `"nat-instance"` | no |
| <a name="input_vpc_fck_nat_instance_type"></a> [vpc\_fck\_nat\_instance\_type](#input\_vpc\_fck\_nat\_instance\_type) | Name of the FCK NAT instance if using a custom NAT setup | `string` | `"t4g.micro"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name for the VPC resource | `string` | n/a | yes |
| <a name="input_vpc_one_nat_gateway_per_az"></a> [vpc\_one\_nat\_gateway\_per\_az](#input\_vpc\_one\_nat\_gateway\_per\_az) | Whether to deploy one NAT Gateway per AZ (high availability) | `bool` | `false` | no |
| <a name="input_vpc_public_egress_traffic_using_nat_gw_or_fck_nat"></a> [vpc\_public\_egress\_traffic\_using\_nat\_gw\_or\_fck\_nat](#input\_vpc\_public\_egress\_traffic\_using\_nat\_gw\_or\_fck\_nat) | Method for public egress: 'nat' for NAT Gateway or 'fck\_nat' for custom NAT instance | `string` | `"nat"` | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | List of CIDR blocks for public subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_service_subnets"></a> [vpc\_service\_subnets](#input\_vpc\_service\_subnets) | List of CIDR blocks for service (application) subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_single_nat_gateway"></a> [vpc\_single\_nat\_gateway](#input\_vpc\_single\_nat\_gateway) | Whether to deploy a single NAT Gateway for all AZs | `bool` | `true` | no |
| <a name="input_vpc_tags"></a> [vpc\_tags](#input\_vpc\_tags) | Tags to apply to all VPC resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the ECS cluster |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block associated with the VPC |
| <a name="output_vpc_data_subnets_cidr_blocks"></a> [vpc\_data\_subnets\_cidr\_blocks](#output\_vpc\_data\_subnets\_cidr\_blocks) | List of CIDR blocks for the intra (data) subnets |
| <a name="output_vpc_data_subnets_ids"></a> [vpc\_data\_subnets\_ids](#output\_vpc\_data\_subnets\_ids) | List of intra (data) subnet IDs |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the created VPC |
| <a name="output_vpc_public_subnets_cidr_blocks"></a> [vpc\_public\_subnets\_cidr\_blocks](#output\_vpc\_public\_subnets\_cidr\_blocks) | List of CIDR blocks for the public subnets |
| <a name="output_vpc_public_subnets_ids"></a> [vpc\_public\_subnets\_ids](#output\_vpc\_public\_subnets\_ids) | List of public subnet IDs created in the VPC |
| <a name="output_vpc_service_subnets_cidr_blocks"></a> [vpc\_service\_subnets\_cidr\_blocks](#output\_vpc\_service\_subnets\_cidr\_blocks) | List of CIDR blocks for the private (service) subnets |
| <a name="output_vpc_service_subnets_ids"></a> [vpc\_service\_subnets\_ids](#output\_vpc\_service\_subnets\_ids) | List of private (service) subnet IDs |
