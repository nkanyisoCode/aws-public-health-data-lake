# Optional RDS PostgreSQL warehouse — disabled by default in dev to save cost.

resource "aws_db_instance" "warehouse" {
  count = var.enable_rds ? 1 : 0

  identifier     = "health-warehouse-${var.env}"
  engine         = "postgres"
  engine_version = "16.4"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true

  db_name  = "health"
  username = "dbadmin"

  manage_master_user_password = true

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection

  tags = {
    Name = "health-warehouse-${var.env}"
  }
}
