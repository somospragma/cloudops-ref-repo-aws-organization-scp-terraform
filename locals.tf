# Local values and transformations
# PC-IAC-003: Nomenclature construction
# PC-IAC-012: Data structures and reusable locals

locals {
  # Governance prefix for resource naming (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # SCP resource type abbreviation
  scp_type = "scp"

  # Construct SCP names following PC-IAC-003 pattern: {client}-{project}-{environment}-{type}-{key}
  scp_names = {
    for key, policy in var.scp_policies :
    key => "${local.governance_prefix}-${local.scp_type}-${key}"
  }

  # Transform SCP policies with constructed names and tags
  scp_policies_transformed = {
    for key, policy in var.scp_policies :
    key => merge(policy, {
      name = local.scp_names[key]
      tags = merge(
        { Name = local.scp_names[key] },
        policy.additional_tags
      )
    })
  }

  # Flatten SCP attachments for resource creation
  scp_attachments = flatten([
    for scp_key, scp_config in local.scp_policies_transformed : [
      for target_id in(scp_config.target_id != "" ? [scp_config.target_id] : []) : {
        scp_key    = scp_key
        target_id  = target_id
        target_type = scp_config.target_type
        policy_id  = aws_organizations_policy.scp[scp_key].id
      }
    ]
  ])

  # Map for easy lookup of attachments
  scp_attachments_map = {
    for attachment in local.scp_attachments :
    "${attachment.scp_key}-${attachment.target_id}" => attachment
  }
}
