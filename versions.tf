# Terraform version and provider requirements
# PC-IAC-005: Provider configuration and alias management
# PC-IAC-006: Version pinning and stability

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0.0"
      configuration_aliases = [aws.project]
    }
  }
}
