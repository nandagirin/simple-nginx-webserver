module "s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "test-account-terraform-state-backend"

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowOrgAccessOnly"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::test-account-terraform-state-backend",
          "arn:aws:s3:::test-account-terraform-state-backend/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = "o-k6jr2nosre"
          }
        }
      }
    ]
  })

  versioning = {
    enabled = true
  }
}
