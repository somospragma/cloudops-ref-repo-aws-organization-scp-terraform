# Local values and transformations
# PC-IAC-003: Nomenclature construction
# PC-IAC-012: Data structures and reusable locals

locals {
  # ============================================================================
  # ORGANIZATION ROOT ID - Shared across all groups
  # ============================================================================
  organization_root_id = var.organization_root_id

  # ============================================================================
  # POC ENVIRONMENT GROUP - Proof of Concept and Testing
  # ============================================================================
  # Set to empty string to create policies WITHOUT attaching them
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
        category = "governance"
        severity = "medium"
        group    = "poc"
        version  = "poc"
      }
    }

    deny_without_required_tags_poc_part2 = {
      name            = "Deny Without Required Tags (POC Part 2)"
      description     = "POC version: Enforces cost-center and owner tags"
      policy_document = local.poc_deny_without_required_tags_part2_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_poc
      additional_tags = {
        category = "governance"
        severity = "medium"
        group    = "poc"
        version  = "poc"
      }
    }
  }

  # ============================================================================
  # PROD ENVIRONMENT GROUP - Production with Strict Controls
  # ============================================================================
  # Set to empty string to create policies WITHOUT attaching them
  scp_target_id_prod = var.policy_ou_id_prod != "" ? var.policy_ou_id_prod : ""

  # PROD Policy Files
  prod_deny_without_required_tags_part1_policy = file("${path.module}/scp-policies/prod/deny-without-required-tags-part1.json")
  prod_deny_without_required_tags_part2_policy = file("${path.module}/scp-policies/prod/deny-without-required-tags-part2.json")
  prod_deny_without_required_tags_part3_policy = file("${path.module}/scp-policies/prod/deny-without-required-tags-part3.json")

  # PROD Policies Transformed
  scp_policies_prod_transformed = {
    deny_without_required_tags_part1 = {
      name            = "Deny Without Required Tags Part 1 (PROD)"
      description     = "Enforces project and environment tags in production"
      policy_document = local.prod_deny_without_required_tags_part1_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        category = "governance"
        severity = "medium"
        group    = "prod"
      }
    }

    deny_without_required_tags_part2 = {
      name            = "Deny Without Required Tags Part 2 (PROD)"
      description     = "Enforces territory and country tags in production"
      policy_document = local.prod_deny_without_required_tags_part2_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        category = "governance"
        severity = "medium"
        group    = "prod"
      }
    }

    deny_without_required_tags_part3 = {
      name            = "Deny Without Required Tags Part 3 (PROD)"
      description     = "Enforces cliente, owner, and cost-center tags in production"
      policy_document = local.prod_deny_without_required_tags_part3_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        category = "governance"
        severity = "medium"
        group    = "prod"
      }
    }
  }

  # ============================================================================
  # SUSPENDED ENVIRONMENT GROUP - Account Suspension/Quarantine
  # ============================================================================
  # Set to empty string to create policies WITHOUT attaching them
  scp_target_id_suspended = var.policy_ou_id_suspended != "" ? var.policy_ou_id_suspended : ""

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
        category = "governance"
        severity = "critical"
        group    = "suspended"
        Purpose  = "account-suspension"
      }
    }
  }

  # ============================================================================
  # SHARED ENVIRONMENT GROUP - Shared Services and Cross-Account Resources
  # ============================================================================
  # Set to empty string to create policies WITHOUT attaching them
  scp_target_id_shared = var.policy_ou_id_shared != "" ? var.policy_ou_id_shared : ""

  # SHARED Policy Files
  shared_deny_modify_audit_roles_policy = file("${path.module}/scp-policies/shared/deny-modify-audit-roles.json")
  shared_deny_create_user_iam_policy    = file("${path.module}/scp-policies/shared/deny-create-user-iam.json")
  shared_deny_disable_cloudtrail_policy = file("${path.module}/scp-policies/shared/deny-disable-cloudtrail.json")
  shared_deny_leave_organization_policy = file("${path.module}/scp-policies/shared/deny-leave-organization.json")
  shared_deny_root_access_keys_policy   = file("${path.module}/scp-policies/shared/deny-root-access-keys.json")

  # SHARED Policies Transformed
  scp_policies_shared_transformed = {
    deny_modify_audit_roles = {
      name            = "Deny Audit Role Modification (SHARED)"
      description     = "Prevents modification of audit and control tower roles in shared services"
      policy_document = local.shared_deny_modify_audit_roles_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        category = "compliance"
        severity = "critical"
        group    = "shared"
      }
    }

    deny_create_user_iam = {
      name            = "Deny Create User IAM (SHARED)"
      description     = "Restricts IAM user creation in shared services"
      policy_document = local.shared_deny_create_user_iam_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        category = "security"
        severity = "high"
        group    = "shared"
      }
    }

    deny_disable_cloudtrail = {
      name            = "Deny Disable CloudTrail (SHARED)"
      description     = "Prevents disabling CloudTrail in shared services"
      policy_document = local.shared_deny_disable_cloudtrail_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        category = "compliance"
        severity = "critical"
        group    = "shared"
      }
    }

    deny_leave_organization = {
      name            = "Deny Leave Organization (SHARED)"
      description     = "Prevents accounts from leaving the organization"
      policy_document = local.shared_deny_leave_organization_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        category = "governance"
        severity = "critical"
        group    = "shared"
      }
    }

    deny_root_access_keys = {
      name            = "Deny Root Access Keys (SHARED)"
      description     = "Prevents creation and use of root account access keys"
      policy_document = local.shared_deny_root_access_keys_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_shared
      additional_tags = {
        category = "security"
        severity = "critical"
        group    = "shared"
      }
    }
  }
}
