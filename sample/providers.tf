# Provider configuration for sample
# PC-IAC-005: Provider configuration with alias

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  alias  = "principal"
  region = var.aws_region

  # Uncomment to assume a specific role
  # assume_role {
  #   role_arn = var.deploy_role_arn
  # }

  default_tags {
    tags = var.common_tags
  }
}
