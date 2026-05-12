# Provider Configuration
# PC-IAC-005: Provider configuration and alias management
# Note: The provider is injected from the root module (IaC Reference)
# This file documents the expected provider configuration

# The aws.project provider alias is injected from the root module
# and must be configured with:
# - region: us-east-1 (AWS Organizations is a global service)
# - assume_role: with appropriate permissions for SCP management
# - default_tags: with common_tags from PC-IAC-004
