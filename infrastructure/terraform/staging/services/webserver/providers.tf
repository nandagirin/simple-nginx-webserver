provider "aws" {
  allowed_account_ids = ["054183072154"]
  profile             = "test-account"
  region              = "ap-southeast-1"

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "staging"
      Context     = "service"
      Service     = "simple-webserver-2"
    }
  }
}
