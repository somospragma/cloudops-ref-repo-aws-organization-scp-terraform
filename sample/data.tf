# Data sources for sample implementation
# PC-IAC-011: Data sources and external data consumption
# PC-IAC-026: Fetch dynamic IDs for transformation in locals.tf

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get organization information
data "aws_organizations_organization" "root" {}
