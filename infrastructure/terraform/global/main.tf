resource "aws_route53_zone" "grnnd_online" {
  name = "grnnd.online"

  tags = {
    Terraform   = "true"
    Environment = "global"
    Context     = "dns"
  }
}

resource "aws_acm_certificate" "grnnd_online" {
  domain_name       = "grnnd.online"
  validation_method = "DNS"

  subject_alternative_names = [ "*.grnnd.online" ]

  tags = {
    Terraform   = "true"
    Environment = "global"
    Context     = "acm"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "grnnd_online_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.grnnd_online.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.grnnd_online.zone_id

  lifecycle {
    create_before_destroy = true
  }
}
