data "terraform_remote_state" "infra_foundation" {
  backend = "s3"
  config = {
    allowed_account_ids = ["054183072154"]
    region              = "ap-southeast-1"
    bucket              = "test-account-terraform-state-backend"
    key                 = "infrastructure/terraform/staging/infra-foundation"
    profile             = "test-account"
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    allowed_account_ids = ["054183072154"]
    region              = "ap-southeast-1"
    bucket              = "test-account-terraform-state-backend"
    key                 = "infrastructure/terraform/global"
    profile             = "test-account"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
