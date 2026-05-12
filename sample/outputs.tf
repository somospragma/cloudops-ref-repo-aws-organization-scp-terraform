# Sample outputs for validation
# PC-IAC-007: Output standards
# Outputs for each environment group: poc, prod, suspended, shared

# POC Environment Outputs
output "scp_policy_ids_poc" {
  description = "Map of created SCP policy IDs for POC environment"
  value       = module.organization_scps_poc.scp_policy_ids
}

output "scp_attachments_poc" {
  description = "Details of SCP attachments for POC environment"
  value       = module.organization_scps_poc.scp_attachments
}

# PROD Environment Outputs
output "scp_policy_ids_prod" {
  description = "Map of created SCP policy IDs for PROD environment"
  value       = module.organization_scps_prod.scp_policy_ids
}

output "scp_attachments_prod" {
  description = "Details of SCP attachments for PROD environment"
  value       = module.organization_scps_prod.scp_attachments
}

# SUSPENDED Account Outputs
output "scp_policy_ids_suspended" {
  description = "Map of created SCP policy IDs for SUSPENDED accounts"
  value       = module.organization_scps_suspended.scp_policy_ids
}

output "scp_attachments_suspended" {
  description = "Details of SCP attachments for SUSPENDED accounts"
  value       = module.organization_scps_suspended.scp_attachments
}

# SHARED Services Outputs
output "scp_policy_ids_shared" {
  description = "Map of created SCP policy IDs for SHARED services"
  value       = module.organization_scps_shared.scp_policy_ids
}

output "scp_attachments_shared" {
  description = "Details of SCP attachments for SHARED services"
  value       = module.organization_scps_shared.scp_attachments
}

# Organization Information
output "organization_root_id" {
  description = "AWS Organization root ID"
  value       = data.aws_organizations_organization.root.roots[0].id
}

output "current_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed SCP policies by group"
  value = {
    poc = {
      policy_count = length(module.organization_scps_poc.scp_policy_ids)
      policies     = keys(module.organization_scps_poc.scp_policy_ids)
    }
    prod = {
      policy_count = length(module.organization_scps_prod.scp_policy_ids)
      policies     = keys(module.organization_scps_prod.scp_policy_ids)
    }
    suspended = {
      policy_count = length(module.organization_scps_suspended.scp_policy_ids)
      policies     = keys(module.organization_scps_suspended.scp_policy_ids)
    }
    shared = {
      policy_count = length(module.organization_scps_shared.scp_policy_ids)
      policies     = keys(module.organization_scps_shared.scp_policy_ids)
    }
  }
}
