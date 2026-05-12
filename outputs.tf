# Module Outputs
# PC-IAC-007: Output standards - expose only granular ARNs/IDs
# PC-IAC-014: Splat expressions for clean extraction

output "scp_policies" {
  description = "Map of created SCP policies with their IDs and ARNs"
  value = {
    for key, policy in aws_organizations_policy.scp :
    key => {
      id          = policy.id
      arn         = policy.arn
      name        = policy.name
      description = policy.description
      type        = policy.type
    }
  }
}

output "scp_policy_ids" {
  description = "Map of SCP policy keys to their IDs (PC-IAC-007)"
  value = {
    for key, policy in aws_organizations_policy.scp :
    key => policy.id
  }
}

output "scp_policy_arns" {
  description = "Map of SCP policy keys to their ARNs (PC-IAC-007)"
  value = {
    for key, policy in aws_organizations_policy.scp :
    key => policy.arn
  }
}

output "scp_attachments" {
  description = "Map of SCP attachments with target information"
  value = {
    for key, attachment in aws_organizations_policy_attachment.scp :
    key => {
      policy_id  = attachment.policy_id
      target_id  = attachment.target_id
      target_type = local.scp_attachments_map[key].target_type
    }
  }
}

output "governance_prefix" {
  description = "Governance prefix used for resource naming (PC-IAC-003)"
  value       = local.governance_prefix
}
