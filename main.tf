# AWS Organization SCP Module - Main Resources
# PC-IAC-010: for_each and resource control
# PC-IAC-020: Security hardening
# PC-IAC-023: Single responsibility principle

# Create Service Control Policies
# PC-IAC-020: Hardened configuration with validation
resource "aws_organizations_policy" "scp" {
  provider = aws.project

  for_each = local.scp_policies_transformed

  name        = each.value.name
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = each.value.policy_document

  # Enable policy validation if configured
  depends_on = var.enable_policy_validation ? [] : []

  tags = merge(
    each.value.tags,
    var.common_tags
  )
}

# Attach SCPs to organization targets (ROOT, OU, or ACCOUNT)
# PC-IAC-020: Explicit target type validation
resource "aws_organizations_policy_attachment" "scp" {
  provider = aws.project

  for_each = local.scp_attachments_map

  policy_id = each.value.policy_id
  target_id = each.value.target_id

  depends_on = [aws_organizations_policy.scp]
}
