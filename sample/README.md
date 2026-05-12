# AWS Organization SCP Module - Example Implementation

This directory contains a complete, functional example of how to use the AWS Organization SCP module following the PC-IAC-026 transformation pattern.

## Execution Flow (PC-IAC-026)

The example follows the mandatory transformation pattern:

```
terraform.tfvars → variables.tf → locals.tf → main.tf → module
```

### Step-by-Step Execution

1. **terraform.tfvars** - Declarative configuration without hardcoded IDs
2. **variables.tf** - Variable definitions with types and validation
3. **data.tf** - Data sources to fetch dynamic IDs (organization structure)
4. **locals.tf** - Transform variables by injecting dynamic IDs from data sources
5. **main.tf** - Invoke the module using transformed locals (never raw variables)

## Files Overview

- **terraform.tfvars** - Configuration values (client, project, environment, policies)
- **variables.tf** - Input variable definitions
- **data.tf** - Data sources for organization structure
- **locals.tf** - Transformation logic (PC-IAC-026 pattern)
- **main.tf** - Module invocation with transformed locals
- **outputs.tf** - Output definitions for validation
- **providers.tf** - Provider configuration

## Running the Example

### Prerequisites

1. AWS Organizations must be enabled in your AWS account
2. You must have permissions to manage SCPs in the organization
3. Terraform >= 1.5.0 must be installed

### Execution Steps

```bash
# 1. Initialize Terraform
terraform init

# 2. Validate configuration
terraform validate

# 3. Plan the deployment
terraform plan -out=tfplan

# 4. Apply the configuration
terraform apply tfplan

# 5. View outputs
terraform output
```

## Configuration

Edit `terraform.tfvars` to customize:

- **client**: Your organization/client name
- **project**: Project identifier
- **environment**: Deployment environment (dev, qa, pdn, prod)
- **organization_root_id**: Your AWS Organization root ID
- **policy_ou_id**: OU ID where policies should be attached (optional)

## Example Policies

The example includes three common SCP patterns:

### 1. Deny Root Account Usage

Prevents the root account from being used in member accounts.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyRootAccountUsage",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListUsers",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:root"
        }
      }
    }
  ]
}
```

### 2. Restrict to Allowed Regions

Limits resource creation to specific AWS regions.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyOutsideAllowedRegions",
      "Effect": "Deny",
      "NotAction": [
        "cloudfront:*",
        "iam:*",
        "route53:*",
        "support:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2",
            "eu-west-1"
          ]
        }
      }
    }
  ]
}
```

### 3. Require Tags on Resource Creation

Enforces tagging on resource creation.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyUntaggedResources",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "rds:CreateDBInstance",
        "s3:CreateBucket"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestTag/Environment": "true"
        }
      }
    }
  ]
}
```

## Outputs

After applying the configuration, you'll receive:

- **scp_policy_ids** - Map of created SCP IDs
- **scp_policy_arns** - Map of created SCP ARNs
- **scp_attachments** - Details of policy attachments
- **governance_prefix** - Naming prefix used for resources

## Validation

To verify the SCPs are working correctly:

1. **AWS Console:** Navigate to AWS Organizations → Policies → Service Control Policies
2. **AWS CLI:**
   ```bash
   aws organizations list-policies --filter SERVICE_CONTROL_POLICY
   aws organizations list-targets-for-policy --policy-id <policy-id>
   ```
3. **Policy Simulator:** Use IAM Policy Simulator to test SCP effects

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
```

## Troubleshooting

### Error: "Organization not found"

**Cause:** AWS Organizations is not enabled or you don't have permissions

**Solution:** Enable AWS Organizations in your management account

### Error: "Policy size exceeds maximum"

**Cause:** SCP policy document is larger than 10,240 characters

**Solution:** Split the policy into multiple SCPs or remove unnecessary whitespace

### Error: "Target not found"

**Cause:** The OU or account ID doesn't exist

**Solution:** Verify the target ID in terraform.tfvars matches an actual organization entity

## Next Steps

1. Customize the policies in `terraform.tfvars` for your organization
2. Add additional SCPs as needed
3. Test policies in non-production OUs first
4. Gradually roll out to production OUs
5. Monitor SCP effects using CloudTrail

## References

- [AWS Organizations SCP Documentation](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html)
- [SCP Examples](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html)
- [SCP Evaluation Logic](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_evaluation.html)
