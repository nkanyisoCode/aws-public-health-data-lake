output "github_plan_role_arn" {
  value = var.enable_github_oidc ? aws_iam_role.github_plan[0].arn : null
}

output "github_apply_role_arn" {
  value = var.enable_github_oidc ? aws_iam_role.github_apply[0].arn : null
}
