# AWS Organization Service Control Policies (SCP) Module

## Overview

This Terraform module provides a standardized, production-ready implementation for managing AWS Organization Service Control Policies (SCPs). It follows the Pragma CloudOps PC-IAC governance standards for Infrastructure as Code.

**Module Purpose:** Create and manage Service Control Policies at scale across AWS Organizations, with support for attaching policies to organization roots, organizational units (OUs), and individual accounts.

**Key Features:**
- Dynamic SCP creation with variable substitution
- Support for multiple policy attachments per SCP
- Comprehensive tagging following PC-IAC-004 standards
- Automatic nomenclature generation following PC-IAC-003
- Built-in policy validation
- Terraform state management best practices

---

## Architecture and Design Decisions

### 1. Single Responsibility Principle (PC-IAC-023)

This module focuses exclusively on SCP management within AWS Organizations. It does NOT:
- Create or manage organization structure (roots, OUs, accounts)
- Manage other organization policy types (RCPs, TAGs, etc.)
- Handle IAM policies or permission boundaries

**Rationale:** Separation of concerns ensures the module remains focused, testable, and maintainable. Organization structure management should be handled by a separate module.

### 2. Policy Documents from JSON Files

SCP policy documents are stored as JSON files in the `policies/` directory within the module. This approach:
- Keeps policies separate from Terraform code for better maintainability
- Allows easy version control and review of policy changes
- Enables reuse of policies across different deployments
- Simplifies policy updates without modifying Terraform code

**Structure:**
```
aws-organization-scp-module/
├── policies/
│   ├── deny-root-access.json
│   ├── restrict-regions.json
│   ├── require-tags.json
│   └── [custom-policies].json
└── sample/
    └── locals.tf (loads policies with file())
```

**Loading Policies:**
```hcl
# In sample/locals.tf
deny_root_access_policy = file("${path.module}/../policies/deny-root-access.json")
```

### 3. Flexible Attachment Strategy

The module supports attaching the same SCP to multiple targets (ROOT, OU, ACCOUNT) through the `target_id` variable. This enables:
- Reusable policy definitions
- Simplified management of common policies across the organization
- Reduced code duplication

### 4. Nomenclature and Tagging (PC-IAC-003, PC-IAC-004)

All resources follow the mandatory naming pattern:
```
{client}-{project}-{environment}-scp-{key}
```

Example: `acme-platform-prod-scp-deny-root-access`

This ensures:
- Consistent identification across the organization
- Cost allocation by project and environment
- Automated resource discovery and filtering

---

## Usage

### Basic Example

```hcl
module "organization_scps" {
  source = "../aws-organization-scp-module"

  providers = {
    aws.project = aws.principal
  }

  client      = "acme"
  project     = "platform"
  environment = "prod"

  scp_policies = {
    deny_root_access = {
      name            = "Deny Root Account Usage"
      description     = "Prevents use of the root account in member accounts"
      policy_document = file("${path.module}/../policies/deny-root-access.json")
      target_type     = "OU"
      target_id       = aws_organizations_organizational_unit.security.id
      additional_tags = {
        Category = "Security"
        Severity = "Critical"
      }
    }
    
    restrict_regions = {
      name            = "Restrict to Allowed Regions"
      description     = "Limits resource creation to approved regions"
      policy_document = file("${path.module}/../policies/restrict-regions.json")
      target_type     = "ROOT"
      target_id       = data.aws_organizations_organization.root.roots[0].id
      additional_tags = {
        Category = "Compliance"
      }
    }
  }

  common_tags = {
    Client      = "acme"
    Project     = "platform"
    Environment = "prod"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}
```

### Policy Files

Policy documents are stored as JSON files in the `policies/` directory:

```
aws-organization-scp-module/
├── policies/
│   ├── deny-root-access.json
│   ├── restrict-regions.json
│   ├── require-tags.json
│   └── [your-custom-policies].json
```

Load policies using the `file()` function:
```hcl
policy_document = file("${path.module}/../policies/deny-root-access.json")
```

### Outputs

```hcl
# Access created SCP IDs
output "scp_ids" {
  value = module.organization_scps.scp_policy_ids
}

# Access SCP ARNs for reference in other modules
output "scp_arns" {
  value = module.organization_scps.scp_policy_arns
}
```

---

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `client` | `string` | Yes | Client/business unit name (1-10 chars, lowercase alphanumeric) |
| `project` | `string` | Yes | Project name (1-15 chars, lowercase alphanumeric) |
| `environment` | `string` | Yes | Environment: `dev`, `qa`, `pdn`, or `prod` |
| `scp_policies` | `map(object)` | Yes | Map of SCP policies to create (see structure below) |
| `common_tags` | `map(string)` | Yes | Common tags including Client, Project, Environment, Owner, CostCenter |
| `enable_policy_validation` | `bool` | No | Enable SCP policy validation (default: `true`) |

### SCP Policy Object Structure

```hcl
scp_policies = {
  policy_key = {
    name            = "Policy Name"                    # Required: 1-128 chars
    description     = "Policy description"             # Optional
    policy_document = jsonencode({...})               # Required: Valid JSON policy
    target_type     = "OU"                            # Optional: ROOT, OU, or ACCOUNT (default: OU)
    target_id       = "ou-xxxx-yyyyyyyy"              # Optional: Target ID for attachment
    additional_tags = { Category = "Security" }       # Optional: Additional tags
  }
}
```

---

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `scp_policies` | `map(object)` | Complete SCP policy details (ID, ARN, name, description) |
| `scp_policy_ids` | `map(string)` | Map of policy keys to their IDs |
| `scp_policy_arns` | `map(string)` | Map of policy keys to their ARNs |
| `scp_attachments` | `map(object)` | SCP attachment details (policy_id, target_id, target_type) |
| `governance_prefix` | `string` | Governance prefix used for naming (PC-IAC-003) |

---

## Requirements

| Name | Version |
|------|---------|
| `terraform` | >= 1.5.0 |
| `aws` | >= 5.0.0 |

---

## Compliance and Governance

### PC-IAC Rules Applied

| Rule | Implementation | Details |
|------|----------------|---------|
| **PC-IAC-001** | Module Structure | 10 root files + 8 sample files following mandatory structure |
| **PC-IAC-002** | Variables | Governance variables (client, project, environment) with validation |
| **PC-IAC-003** | Nomenclature | Dynamic naming: `{client}-{project}-{environment}-scp-{key}` |
| **PC-IAC-004** | Tagging | Common tags + explicit Name tag + additional_tags support |
| **PC-IAC-005** | Providers | Provider alias `aws.project` injected from root module |
| **PC-IAC-006** | Versions | Pinned Terraform (>=1.5.0) and AWS provider (>=5.0.0) |
| **PC-IAC-007** | Outputs | Granular outputs: IDs, ARNs, attachment details |
| **PC-IAC-010** | for_each | Dynamic resource creation using `for_each` for stability |
| **PC-IAC-020** | Security | Policy validation enabled by default; explicit target type validation |
| **PC-IAC-023** | Responsibility | Module focuses only on SCP management; no organization structure |

### AWS Well-Architected Alignment

- **Operational Excellence:** Consistent naming and tagging enable automated discovery and management
- **Security:** Policy validation and explicit target type validation prevent misconfiguration
- **Cost Optimization:** Tagging by client and project enables cost allocation and chargeback

---

## Important Notes

### SCP Limitations

1. **Maximum Size:** SCPs are limited to 10,240 characters. Complex policies may need to be split.
2. **Evaluation Logic:** SCPs use a deny-by-default model. Explicit Allow statements are required at each organizational level.
3. **Management Account:** SCPs do NOT apply to the management account. Only member accounts are affected.
4. **Service-Linked Roles:** SCPs cannot restrict service-linked roles.

### Best Practices

1. **Policy Documents:** Store policy documents in separate files for maintainability
2. **Testing:** Use AWS Organizations Policy Simulator to test SCP effects before deployment
3. **Gradual Rollout:** Attach SCPs to test OUs first, then expand to production
4. **Documentation:** Document the business rationale for each SCP in the `description` field
5. **Monitoring:** Use CloudTrail to monitor SCP attachment and modification events

### Common SCP Patterns

The module supports both:
- **Deny-list strategy:** Explicitly deny specific actions (most common)
- **Allow-list strategy:** Explicitly allow specific actions (more restrictive)

Examples are provided in the `sample/` directory.

---

## Troubleshooting

### Policy Attachment Fails

**Issue:** `aws_organizations_policy_attachment` fails with "Target not found"

**Solution:** Ensure the `target_id` is a valid organization root, OU, or account ID. Verify the target exists before applying the module.

### Policy Size Exceeded

**Issue:** Policy document exceeds 10,240 characters

**Solution:** Split the policy into multiple SCPs or remove unnecessary whitespace from the JSON document.

### Changes Not Taking Effect

**Issue:** SCP changes don't affect IAM permissions immediately

**Solution:** SCPs are evaluated at request time. Changes take effect immediately, but cached credentials may need to expire. Clear browser cache or re-authenticate.

---

## Related Modules

- **aws-organization-structure-module:** Manages organization roots, OUs, and accounts
- **aws-iam-policies-module:** Manages IAM policies and permission boundaries
- **aws-organization-rcp-module:** Manages Resource Control Policies (RCPs)

---

## License

This module is provided as part of the Pragma CloudOps governance framework.

---

## Support

For issues, questions, or contributions, please refer to the Pragma CloudOps documentation and governance standards.
