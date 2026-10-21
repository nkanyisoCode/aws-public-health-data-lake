output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "s3_vpce_id" {
  value = aws_vpc_endpoint.s3.id
}

output "db_subnet_group_name" {
  value = var.enable_rds ? aws_db_subnet_group.private[0].name : null
}
