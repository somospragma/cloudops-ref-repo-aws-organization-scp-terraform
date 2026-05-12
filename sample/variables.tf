# Sample variables for AWS Organization SCP module
# PC-IAC-002: Variable declaration standards
# Segmented by environment groups: poc, prod, suspended, shared

variable "client" {
  type        = string
  description = "Client name for resource naming"
}

variable "project" {
  type        = string
  description = "Project name for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, qa, pdn, prod)"
}

variable "organization_root_id" {
  type        = string
  description = "AWS Organization root ID (e.g., r-xxxx)"
}

# POC Environment Variables
variable "policy_ou_id_poc" {
  type        = string
  description = "OU ID where POC SCPs should be attached (optional)"
  default     = ""
}

variable "enable_poc_policies" {
  type        = bool
  description = "Enable deployment of POC environment policies"
  default     = true
}

# PROD Environment Variables
variable "policy_ou_id_prod" {
  type        = string
  description = "OU ID where PROD SCPs should be attached (optional)"
  default     = ""
}

variable "enable_prod_policies" {
  type        = bool
  description = "Enable deployment of PROD environment policies"
  default     = true
}

# SUSPENDED Account Variables
variable "policy_ou_id_suspended" {
  type        = string
  description = "OU ID where SUSPENDED SCPs should be attached (optional)"
  default     = ""
}

variable "enable_suspended_policies" {
  type        = bool
  description = "Enable deployment of SUSPENDED account policies"
  default     = true
}

# SHARED Services Variables
variable "policy_ou_id_shared" {
  type        = string
  description = "OU ID where SHARED SCPs should be attached (optional)"
  default     = ""
}

variable "enable_shared_policies" {
  type        = bool
  description = "Enable deployment of SHARED services policies"
  default     = true
}

variable "aws_region" {
  type        = string
  description = "AWS region for provider configuration"
  default     = "us-east-1"
}

variable "deploy_role_arn" {
  type        = string
  description = "ARN of the role to assume for deployment"
  default     = ""
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default = {
    Client      = "example"
    Project     = "platform"
    Environment = "dev"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}

