# AWS Organization SCP Module - Segmented Invocations
# PC-IAC-026: Invoke module using transformed locals (never raw variables)
# PC-IAC-013: Module invocation ordering
# 4 independent module invocations for each environment group

# ============================================================================
# POC Environment - Proof of Concept and Testing
# ============================================================================
module "organization_scps_poc" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }

  client       = var.client
  project      = var.project
  environment  = var.environment
  scp_policies = local.scp_policies_poc_transformed
  common_tags  = merge(
    var.common_tags,
    {
      Group       = "poc"
      ManagedBy   = "Terraform"
    }
  )
}

# ============================================================================
# PROD Environment - Production with Strict Controls
# ============================================================================
module "organization_scps_prod" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }

  client       = var.client
  project      = var.project
  environment  = var.environment
  scp_policies = local.scp_policies_prod_transformed
  common_tags  = merge(
    var.common_tags,
    {
      Group       = "prod"
      ManagedBy   = "Terraform"
    }
  )
}

# ============================================================================
# SUSPENDED Accounts - Account Suspension/Quarantine
# ============================================================================
module "organization_scps_suspended" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }

  client       = var.client
  project      = var.project
  environment  = var.environment
  scp_policies = local.scp_policies_suspended_transformed
  common_tags  = merge(
    var.common_tags,
    {
      Group       = "suspended"
      ManagedBy   = "Terraform"
    }
  )
}

# ============================================================================
# SHARED Services - Shared Infrastructure and Cross-Account Resources
# ============================================================================
module "organization_scps_shared" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }

  client       = var.client
  project      = var.project
  environment  = var.environment
  scp_policies = local.scp_policies_shared_transformed
  common_tags  = merge(
    var.common_tags,
    {
      Group       = "shared"
      ManagedBy   = "Terraform"
    }
  )
}
