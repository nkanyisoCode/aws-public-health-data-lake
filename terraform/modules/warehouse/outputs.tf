output "db_endpoint" {
  value = var.enable_rds ? aws_db_instance.warehouse[0].endpoint : null
}

output "db_arn" {
  value = var.enable_rds ? aws_db_instance.warehouse[0].arn : null
}

output "master_user_secret_arn" {
  value = var.enable_rds ? aws_db_instance.warehouse[0].master_user_secret[0].secret_arn : null
}
