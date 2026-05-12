# AWS Organization SCP Policies - Consolidated Locals
# PC-IAC-026: Transform terraform.tfvars by injecting dynamic IDs from data sources
# PC-IAC-012: Data structures and reusable locals
# All 4 environment groups (poc, prod, suspended, shared) defined in a single locals block

locals {
  # ============================================================================
  # ORGANIZATION ROOT ID - Shared across all groups
  # ============================================================================
  organization_root_id = data.aws_organizations_organization.root.roots[0].id

  # ============================================================================
  # POC ENVIRONMENT GROUP - Proof of Concept and Testing
  # ============================================================================
  scp_target_id_poc = var.policy_ou_id_poc != "" ? var.policy_ou_id_poc : local.organization_root_id

  # POC Policy Files
  poc_deny_without_required_tags_part1_policy = file("${path.module}/scp-policies/poc/deny-without-required-tags-poc-part1.json")
  poc_deny_without_required_tags_part2_policy = file("${path.module}/scp-policies/poc/deny-without-required-tags-poc-part2.json")

  # POC Policies Transformed
  scp_policies_poc_transformed = {
    deny_without_required_tags_poc_part1 = {
      name            = "Deny Without Required Tags (POC Part 1)"
      description     = "POC version: Enforces comprehensive tagging requirements"
      policy_document = local.poc_deny_without_required_tags_part1_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_poc
      additional_tags = {
        Category = "Governance"
        Severity = "Medium"
        Group    = "poc"
        Version  = "POC"
      }
    }

    deny_without_required_tags_poc_part2 = {
      name            = "Deny Without Required Tags (POC Part 2)"
      description     = "POC version: Enforces cost-center and owner tags"
      policy_document = local.poc_deny_without_required_tags_part2_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_poc
      additional_tags = {
        Category = "Governance"
        Severity = "Medium"
        Group    = "poc"
        Version  = "POC"
      }
    }
  }

  # ============================================================================
  # PROD ENVIRONMENT GROUP - Production with Strict Controls
  # ============================================================================
  scp_target_id_prod = var.policy_ou_id_prod != "" ? var.policy_ou_id_prod : local.organization_root_id

  # PROD Policy Files
  prod_deny_without_required_tags_part1_policy = file("${path.module}/scp-policies/prod/deny-without-required-tags-part1.json")
  prod_deny_without_required_tags_part2_policy = file("${path.module}/scp-policies/prod/deny-without-required-tags-part2.json")
  prod_deny_without_required_tags_part3_policy = file("${path.module}/scp-policies/prod/deny-without-required-tags-part3.json")

  # PROD Policies Transformed
  scp_policies_prod_transformed = {
    deny_without_required_tags_part1 = {
      name            = "Deny Without Required Tags (PROD Part 1)"
      description     = "Enforces comprehensive tagging requirements in production"
      policy_document = local.prod_deny_without_required_tags_part1_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Governance"
        Severity = "Medium"
        Group    = "prod"
      }
    }

    deny_without_required_tags_part2 = {
      name            = "Deny Without Required Tags (PROD Part 2)"
      description     = "Enforces cost-center and owner tags in production"
      policy_document = local.prod_deny_without_required_tags_part2_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Governance"
        Severity = "Medium"
        Group    = "prod"
      }
    }

    deny_without_required_tags_part3 = {
      name            = "Deny Without Required Tags (PROD Part 3)"
      description     = "Enforces additional tagging requirements in production"
      policy_document = local.prod_deny_without_required_tags_part3_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Governance"
        Severity = "Medium"
        Group    = "prod"
      }
    }
  }

  # ============================================================================
  # SUSPENDED ENVIRONMENT GROUP - Account Suspension/Quarantine
  # ============================================================================
  scp_target_id_suspended = var.policy_ou_id_suspended != "" ? var.policy_ou_id_suspended : local.organization_root_id

  # SUSPENDED Policy Files
  suspended_deny_all_suspended_policy = file("${path.module}/scp-policies/suspended/deny-all-suspended.json")

  # SUSPENDED Policies Transformed
  scp_policies_suspended_transformed = {
    deny_all_suspended = {
      name            = "Deny All (Suspended Account)"
      description     = "Suspends all access except admin and billing operations for quarantined accounts"
      policy_document = local.suspended_deny_all_suspended_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_suspended
      additional_tags = {
        Category = "Governance"
        Severity = "Critical"
        Group    = "suspended"
        Purpose  = "Account Suspension"
      }
    }
  }

  # ============================================================================
  # SHARED ENVIRONMENT GROUP - Shared Services and Cross-Account Resources
  # ============================================================================
  scp_target_id_shared = var.policy_ou_id_shared != "" ? var.policy_ou_id_shared : local.organization_root_id

  # SHARED Policy Files
  shared_deny_create_user_iam_policy       = file("${path.module}/scp-policies/shared/deny-create-user-iam.json")
  shared_deny_disable_cloudtrail_policy    = file("${path.module}/scp-policies/shared/deny-disable-cloudtrail.json")
  shared_deny_leave_organization_policy    = file("${path.module}/scp-policies/shared/deny-leave-organization.json")
  shared_deny_modify_audit_roles_policy    = file("${path.module}/scp-policies/shared/deny-modify-audit-roles.json")
  shared_deny_root_access_keys_policy      = file("${path.module}/scp-policies/shared/deny-root-access-keys.json")

  # SHARED Policies Transformed
  scp_policies_shared_transformed = {
    deny_create_user_iam = {
      name            = "Deny Create User IAM (SHARED)"
      description     = "Prevents creation of IAM users in shared services"
      policy_document = local.shared_deny_create_user_iam_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        Category = "Security"
        Severity = "High"
        Group    = "shared"
      }
    }

    deny_disable_cloudtrail = {
      name            = "Deny CloudTrail Disablement (SHARED)"
      description     = "Prevents disabling or modifying CloudTrail logging in shared services"
      policy_document = local.shared_deny_disable_cloudtrail_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        Category = "Compliance"
        Severity = "Critical"
        Group    = "shared"
      }
    }

    deny_leave_organization = {
      name            = "Deny Leave Organization (SHARED)"
      description     = "Prevents shared service accounts from leaving the organization"
      policy_document = local.shared_deny_leave_organization_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        Category = "Governance"
        Severity = "High"
        Group    = "shared"
      }
    }

    deny_modify_audit_roles = {
      name            = "Deny Audit Role Modification (SHARED)"
      description     = "Prevents modification of audit and control tower roles in shared services"
      policy_document = local.shared_deny_modify_audit_roles_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        Category = "Compliance"
        Severity = "Critical"
        Group    = "shared"
      }
    }

    deny_root_access_keys = {
      name            = "Deny Root Access Key Creation (SHARED)"
      description     = "Prevents creation of access keys for root account in shared services"
      policy_document = local.shared_deny_root_access_keys_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        Category = "Security"
        Severity = "Critical"
        Group    = "shared"
      }
    }
  }

  # ============================================================================
  # CONSOLIDATED POLICIES MAP - Merge all environment groups
  # ============================================================================
  scp_policies_transformed = merge(
    local.scp_policies_poc_transformed,
    local.scp_policies_prod_transformed,
    local.scp_policies_suspended_transformed,
    local.scp_policies_shared_transformed
  )
}
