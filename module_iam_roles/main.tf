resource "aws_iam_role" "default" {
  name                = var.role_name
  assume_role_policy  = var.assume_role_policy
  managed_policy_arns = var.managed_policy_arns
  #inline_policy         = var.inline_policy
  force_detach_policies = var.force_detach_policies
  path                  = var.path
  description           = var.description
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary
  tags                  = var.tags
}