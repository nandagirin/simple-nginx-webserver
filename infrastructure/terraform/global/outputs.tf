output "grnnd_online_route53_zone_id" {
  value = aws_route53_zone.grnnd_online.id
}

output "grnnd_online_acm_certificate_arn" {
  value = aws_acm_certificate.grnnd_online.id
}
output "github_actions_iam_role_arn" {
  value = module.iam_github_oidc_role.arn
}
