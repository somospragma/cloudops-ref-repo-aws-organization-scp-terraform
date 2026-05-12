# Variables for AWS Organization SCP Module
# PC-IAC-002: Variable declaration standards and governance variables

variable "client" {
  type        = string
  description = "Client or business unit name for resource naming and tagging (PC-IAC-003)"
  
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "Client name must be between 1 and 10 characters."
  }
}

variable "project" {
  type        = string
  description = "Project name for resource naming and tagging (PC-IAC-003)"
  
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "Project name must be between 1 and 15 characters."
  }
}

variable "environment" {
  type        = string
  description = "Environment name (dev, qa, pdn) for resource naming and tagging (PC-IAC-003)"
  
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, pdn, prod."
  }
}

variable "scp_policies" {
  type = map(object({
    name            = string
    description     = optional(string, "")
    policy_document = string
    target_type     = optional(string, "OU")
    target_id       = optional(string, "")
    additional_tags = optional(map(string), {})
  }))
  
  description = "Map of SCP policies to create and manage (PC-IAC-002, PC-IAC-010)"
  
  validation {
    condition = alltrue([
      for key, policy in var.scp_policies : 
      length(policy.name) > 0 && length(policy.name) <= 128
    ])
    error_message = "Each SCP name must be between 1 and 128 characters."
  }
  
  validation {
    condition = alltrue([
      for key, policy in var.scp_policies : 
      contains(["ROOT", "OU", "ACCOUNT"], policy.target_type)
    ])
    error_message = "Target type must be one of: ROOT, OU, ACCOUNT."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources (PC-IAC-004)"
  
  validation {
    condition = alltrue([
      for key in ["client", "project", "environment", "owner", "cost-center"] :
      contains(keys(var.common_tags), key)
    ])
    error_message = "common_tags must include: client, project, environment, owner, cost-center."
  }
}

variable "enable_policy_validation" {
  type        = bool
  description = "Enable validation of SCP policy documents (recommended for production)"
  default     = true
}
