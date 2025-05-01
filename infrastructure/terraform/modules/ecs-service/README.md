## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.ecs_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codedeploy_app.ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app) | resource |
| [aws_codedeploy_deployment_group.codedeploy_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group) | resource |
| [aws_ecs_service.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.ecs_task_role_additional_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_task_role_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.codedeploy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.codedeploy_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_additional_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.http_to_https_redirect_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.blue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.green](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.alb_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.alb_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.ssm_configs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_certificate_arn"></a> [alb\_certificate\_arn](#input\_alb\_certificate\_arn) | ARN of the ACM certificate to use for HTTPS listener | `string` | `null` | no |
| <a name="input_alb_ecs_container_name"></a> [alb\_ecs\_container\_name](#input\_alb\_ecs\_container\_name) | Name of the ECS container to register with the ALB target group | `string` | `null` | no |
| <a name="input_alb_ecs_service_port"></a> [alb\_ecs\_service\_port](#input\_alb\_ecs\_service\_port) | Port on the ECS container for ALB to forward traffic to | `number` | `null` | no |
| <a name="input_alb_enable"></a> [alb\_enable](#input\_alb\_enable) | Whether to create an Application Load Balancer for the service | `bool` | `false` | no |
| <a name="input_alb_enable_https_listener"></a> [alb\_enable\_https\_listener](#input\_alb\_enable\_https\_listener) | Whether to enable an HTTPS listener on the ALB | `bool` | `false` | no |
| <a name="input_alb_register_dns_route53"></a> [alb\_register\_dns\_route53](#input\_alb\_register\_dns\_route53) | Whether to register ALB DNS in Route53 | `string` | `"false"` | no |
| <a name="input_alb_route53_domain_name"></a> [alb\_route53\_domain\_name](#input\_alb\_route53\_domain\_name) | Domain name to associate with the ALB in Route53 | `string` | `null` | no |
| <a name="input_alb_route53_zone_id"></a> [alb\_route53\_zone\_id](#input\_alb\_route53\_zone\_id) | Route53 hosted zone ID for DNS registration | `string` | `null` | no |
| <a name="input_alb_vpc_subnets_ids"></a> [alb\_vpc\_subnets\_ids](#input\_alb\_vpc\_subnets\_ids) | List of subnet IDs for the ALB | `list(string)` | `null` | no |
| <a name="input_codedeploy_blue_green_deployment_ready_action"></a> [codedeploy\_blue\_green\_deployment\_ready\_action](#input\_codedeploy\_blue\_green\_deployment\_ready\_action) | Action to take when the new task set is ready (e.g., CONTINUE\_DEPLOYMENT) | `string` | `"CONTINUE_DEPLOYMENT"` | no |
| <a name="input_codedeploy_blue_green_deployment_ready_wait_time_in_minutes"></a> [codedeploy\_blue\_green\_deployment\_ready\_wait\_time\_in\_minutes](#input\_codedeploy\_blue\_green\_deployment\_ready\_wait\_time\_in\_minutes) | Wait time in minutes before continuing blue/green deployment | `number` | `5` | no |
| <a name="input_codedeploy_config_name"></a> [codedeploy\_config\_name](#input\_codedeploy\_config\_name) | Name of the CodeDeploy deployment configuration | `string` | `"CodeDeployDefault.ECSAllAtOnce"` | no |
| <a name="input_codedeploy_deployment_option"></a> [codedeploy\_deployment\_option](#input\_codedeploy\_deployment\_option) | Deployment option for CodeDeploy (e.g., WITH\_TRAFFIC\_CONTROL) | `string` | `"WITH_TRAFFIC_CONTROL"` | no |
| <a name="input_codedeploy_deployment_type"></a> [codedeploy\_deployment\_type](#input\_codedeploy\_deployment\_type) | Type of CodeDeploy deployment (e.g., BLUE\_GREEN) | `string` | `"BLUE_GREEN"` | no |
| <a name="input_codedeploy_enable_auto_rollback_on_deployment_failure"></a> [codedeploy\_enable\_auto\_rollback\_on\_deployment\_failure](#input\_codedeploy\_enable\_auto\_rollback\_on\_deployment\_failure) | Whether to enable automatic rollback on deployment failure | `bool` | `true` | no |
| <a name="input_codedeploy_terminate_blue_instances_on_deployment_success_action"></a> [codedeploy\_terminate\_blue\_instances\_on\_deployment\_success\_action](#input\_codedeploy\_terminate\_blue\_instances\_on\_deployment\_success\_action) | Action to take on the old task set after deployment success | `string` | `"TERMINATE"` | no |
| <a name="input_codedeploy_terminate_blue_instances_on_deployment_success_wait_time_in_minutes"></a> [codedeploy\_terminate\_blue\_instances\_on\_deployment\_success\_wait\_time\_in\_minutes](#input\_codedeploy\_terminate\_blue\_instances\_on\_deployment\_success\_wait\_time\_in\_minutes) | Wait time before terminating old task set (in minutes) | `number` | `1` | no |
| <a name="input_ecs_additional_task_policy"></a> [ecs\_additional\_task\_policy](#input\_ecs\_additional\_task\_policy) | Additional IAM policy to attach to the ECS task role | `any` | `null` | no |
| <a name="input_ecs_cloudwatch_logging_retention_period_in_days"></a> [ecs\_cloudwatch\_logging\_retention\_period\_in\_days](#input\_ecs\_cloudwatch\_logging\_retention\_period\_in\_days) | Retention period for CloudWatch log groups (in days) | `number` | `7` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ARN of the ECS cluster | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS cluster | `string` | `null` | no |
| <a name="input_ecs_container_definitions"></a> [ecs\_container\_definitions](#input\_ecs\_container\_definitions) | List of container definitions for the ECS task | `any` | n/a | yes |
| <a name="input_ecs_cpu"></a> [ecs\_cpu](#input\_ecs\_cpu) | Amount of CPU to allocate for the ECS task (in CPU units) | `number` | `512` | no |
| <a name="input_ecs_deployment_controller"></a> [ecs\_deployment\_controller](#input\_ecs\_deployment\_controller) | Type of deployment controller to use (e.g., ECS, CODE\_DEPLOY) | `string` | `"ECS"` | no |
| <a name="input_ecs_egress_security_group_rules"></a> [ecs\_egress\_security\_group\_rules](#input\_ecs\_egress\_security\_group\_rules) | Egress security group rules for the ECS service | `list(any)` | `[]` | no |
| <a name="input_ecs_enable_cloudwatch_logging"></a> [ecs\_enable\_cloudwatch\_logging](#input\_ecs\_enable\_cloudwatch\_logging) | Whether to enable CloudWatch logging for ECS containers | `bool` | `false` | no |
| <a name="input_ecs_ingress_security_group_rules"></a> [ecs\_ingress\_security\_group\_rules](#input\_ecs\_ingress\_security\_group\_rules) | Ingress security group rules for the ECS service | `list(any)` | `[]` | no |
| <a name="input_ecs_memory"></a> [ecs\_memory](#input\_ecs\_memory) | Amount of memory to allocate for the ECS task (in MiB) | `number` | `1024` | no |
| <a name="input_ecs_task_desired_count"></a> [ecs\_task\_desired\_count](#input\_ecs\_task\_desired\_count) | Number of ECS task instances to run | `number` | `1` | no |
| <a name="input_ecs_volumes"></a> [ecs\_volumes](#input\_ecs\_volumes) | List of volumes to be used by the ECS task | `list(any)` | `[]` | no |
| <a name="input_ecs_vpc_subnets_ids"></a> [ecs\_vpc\_subnets\_ids](#input\_ecs\_vpc\_subnets\_ids) | List of subnet IDs for ECS task networking | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service | `string` | n/a | yes |
| <a name="input_ssm_configs"></a> [ssm\_configs](#input\_ssm\_configs) | List of SSM parameters used in the ECS task | `list(map(any))` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to deploy the ECS service into | `string` | n/a | yes |

## Outputs

No outputs.
