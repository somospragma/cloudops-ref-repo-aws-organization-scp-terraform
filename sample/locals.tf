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
  poc_deny_root_access_policy                 = file("${path.module}/../policies/deny-root-access.json")
  poc_deny_disable_mfa_policy                 = file("${path.module}/../policies/deny-disable-mfa.json")
  poc_deny_without_required_tags_part1_policy = file("${path.module}/../policies/deny-without-required-tags-poc-part1.json")
  poc_deny_without_required_tags_part2_policy = file("${path.module}/../policies/deny-without-required-tags-poc-part2.json")
  poc_restrict_regions_policy                 = file("${path.module}/../policies/restrict-regions.json")

  # POC Policies Transformed
  scp_policies_poc_transformed = {
    deny_root_access = {
      name            = "Deny Root Account Usage (POC)"
      description     = "Prevents use of the root account in POC member accounts"
      policy_document = local.poc_deny_root_access_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_poc
      additional_tags = {
        Category = "Security"
        Severity = "Critical"
        Group    = "poc"
      }
    }

    deny_disable_mfa = {
      name            = "Deny MFA Disablement (POC)"
      description     = "Prevents disabling or deleting MFA devices in POC"
      policy_document = local.poc_deny_disable_mfa_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_poc
      additional_tags = {
        Category = "Security"
        Severity = "High"
        Group    = "poc"
      }
    }

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

    restrict_regions = {
      name            = "Restrict to Allowed Regions (POC)"
      description     = "Limits resource creation to approved regions in POC"
      policy_document = local.poc_restrict_regions_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_poc
      additional_tags = {
        Category = "Governance"
        Severity = "Medium"
        Group    = "poc"
      }
    }
  }

  # ============================================================================
  # PROD ENVIRONMENT GROUP - Production with Strict Controls
  # ============================================================================
  scp_target_id_prod = var.policy_ou_id_prod != "" ? var.policy_ou_id_prod : local.organization_root_id

  # PROD Policy Files
  prod_deny_root_access_policy        = file("${path.module}/../policies/deny-root-access.json")
  prod_deny_root_account_usage_policy = file("${path.module}/../policies/deny-root-account-usage.json")
  prod_deny_root_access_keys_policy   = file("${path.module}/../policies/deny-root-access-keys.json")
  prod_deny_disable_mfa_policy        = file("${path.module}/../policies/deny-disable-mfa.json")
  prod_deny_disable_cloudtrail_policy = file("${path.module}/../policies/deny-disable-cloudtrail.json")

  # PROD Policies Transformed
  scp_policies_prod_transformed = {
    deny_root_access = {
      name            = "Deny Root Account Usage (PROD)"
      description     = "Prevents use of the root account in production member accounts"
      policy_document = local.prod_deny_root_access_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Security"
        Severity = "Critical"
        Group    = "prod"
      }
    }

    deny_root_account_usage = {
      name            = "Deny Root Account Usage (Comprehensive - PROD)"
      description     = "Denies all actions when using root account principal in production"
      policy_document = local.prod_deny_root_account_usage_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Security"
        Severity = "Critical"
        Group    = "prod"
      }
    }

    deny_root_access_keys = {
      name            = "Deny Root Access Key Creation (PROD)"
      description     = "Prevents creation of access keys for root account in production"
      policy_document = local.prod_deny_root_access_keys_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Security"
        Severity = "Critical"
        Group    = "prod"
      }
    }

    deny_disable_mfa = {
      name            = "Deny MFA Disablement (PROD)"
      description     = "Prevents disabling or deleting MFA devices in production"
      policy_document = local.prod_deny_disable_mfa_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Security"
        Severity = "High"
        Group    = "prod"
      }
    }

    deny_disable_cloudtrail = {
      name            = "Deny CloudTrail Disablement (PROD)"
      description     = "Prevents disabling or modifying CloudTrail logging in production"
      policy_document = local.prod_deny_disable_cloudtrail_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Compliance"
        Severity = "Critical"
        Group    = "prod"
      }
    }

    deny_disable_aws_config = {
      name            = "Deny AWS Config Disablement (PROD)"
      description     = "Prevents disabling AWS Config recording and delivery in production"
      policy_document = local.prod_deny_disable_aws_config_policy
      target_type     = "ROOT"
      target_id       = local.scp_target_id_prod
      additional_tags = {
        Category = "Compliance"
        Severity = "High"
        Group    = "prod"
      }
    }

    # ============================================================================
    # SUSPENDED ENVIRONMENT GROUP - Account Suspension/Quarantine
    # ============================================================================
    scp_target_id_suspended = var.policy_ou_id_suspended != "" ? var.policy_ou_id_suspended : local.organization_root_id

    # SUSPENDED Policy Files
    suspended_deny_all_suspended_policy = file("${path.module}/../policies/deny-all-suspended.json")

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
    shared_deny_root_access_policy                     = file("${path.module}/../policies/deny-root-access.json")
    shared_deny_root_account_usage_policy              = file("${path.module}/../policies/deny-root-account-usage.json")
    shared_deny_disable_mfa_policy                     = file("${path.module}/../policies/deny-disable-mfa.json")
    shared_deny_disable_cloudtrail_policy              = file("${path.module}/../policies/deny-disable-cloudtrail.json")
    shared_deny_disable_guardduty_policy               = file("${path.module}/../policies/deny-disable-guardduty.json")
    shared_deny_modify_audit_roles_policy              = file("${path.module}/../policies/deny-modify-audit-roles.json")
    shared_deny_disable_encryption_defaults_policy     = file("${path.module}/../policies/deny-disable-encryption-defaults.json")
    shared_deny_s3_public_access_policy                = file("${path.module}/../policies/deny-s3-public-access.json")
    shared_deny_internet_gateway_creation_policy       = file("${path.module}/../policies/deny-internet-gateway-creation.json")
    shared_deny_leave_organization_policy              = file("${path.module}/../policies/deny-leave-organization.json")
    shared_deny_resources_without_required_tags_policy = file("${path.module}/../policies/deny-resources-without-required-tags.json")
    shared_restrict_regions_policy                     = file("${path.module}/../policies/restrict-regions.json")

    # SHARED Policies Transformed
    scp_policies_shared_transformed = {
      deny_root_access = {
        name            = "Deny Root Account Usage (SHARED)"
        description     = "Prevents use of the root account in shared services"
        policy_document = local.shared_deny_root_access_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Security"
          Severity = "Critical"
          Group    = "shared"
        }
      }

      deny_root_account_usage = {
        name            = "Deny Root Account Usage (Comprehensive - SHARED)"
        description     = "Denies all actions when using root account principal in shared services"
        policy_document = local.shared_deny_root_account_usage_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Security"
          Severity = "Critical"
          Group    = "shared"
        }
      }

      deny_disable_mfa = {
        name            = "Deny MFA Disablement (SHARED)"
        description     = "Prevents disabling or deleting MFA devices in shared services"
        policy_document = local.shared_deny_disable_mfa_policy
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

      deny_disable_guardduty = {
        name            = "Deny GuardDuty Disablement (SHARED)"
        description     = "Prevents disabling or modifying GuardDuty detectors in shared services"
        policy_document = local.shared_deny_disable_guardduty_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Compliance"
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

      deny_disable_encryption_defaults = {
        name            = "Deny Encryption Defaults Disablement (SHARED)"
        description     = "Enforces encryption for EBS volumes and S3 objects in shared services"
        policy_document = local.shared_deny_disable_encryption_defaults_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Data Protection"
          Severity = "High"
          Group    = "shared"
        }
      }

      deny_s3_public_access = {
        name            = "Deny S3 Public Access (SHARED)"
        description     = "Prevents public access to S3 buckets and objects in shared services"
        policy_document = local.shared_deny_s3_public_access_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Data Protection"
          Severity = "High"
          Group    = "shared"
        }
      }

      deny_internet_gateway_creation = {
        name            = "Deny Internet Gateway Creation (SHARED)"
        description     = "Restricts internet gateway creation to network admins in shared services"
        policy_document = local.shared_deny_internet_gateway_creation_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Network"
          Severity = "Medium"
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

      deny_resources_without_required_tags = {
        name            = "Deny Resources Without Required Tags (SHARED)"
        description     = "Enforces required tags on core AWS resources in shared services"
        policy_document = local.shared_deny_resources_without_required_tags_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Governance"
          Severity = "Medium"
          Group    = "shared"
        }
      }

      restrict_regions = {
        name            = "Restrict to Allowed Regions (SHARED)"
        description     = "Limits resource creation to approved regions in shared services"
        policy_document = local.shared_restrict_regions_policy
        target_type     = "ROOT"
        target_id       = local.scp_target_id_shared
        additional_tags = {
          Category = "Governance"
          Severity = "Medium"
          Group    = "shared"
        }
      }
    }
  }
}
