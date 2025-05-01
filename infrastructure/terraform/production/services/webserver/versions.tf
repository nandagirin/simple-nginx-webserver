terraform {
  backend "s3" {
    allowed_account_ids = ["054183072154"]
    region              = "ap-southeast-1"
    bucket              = "test-account-terraform-state-backend"
    key                 = "infrastructure/terraform/production/services/webserver"
    profile             = "test-account"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
