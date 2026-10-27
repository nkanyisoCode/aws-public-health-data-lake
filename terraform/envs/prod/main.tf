provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project     = "health-lake"
      env         = var.env
      owner       = var.owner
      managed_by  = "terraform"
      cost_center = "portfolio"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "network" {
  count  = var.enable_network ? 1 : 0
  source = "../../modules/network"

  env                             = var.env
  region                          = var.region
  enable_rds                      = var.enable_rds
  enable_secrets_manager_endpoint = var.enable_secrets_manager_endpoint
}

module "data_lake" {
  source = "../../modules/data_lake"

  env        = var.env
  owner      = var.owner
  account_id = local.account_id
  s3_vpce_id = var.enable_network ? module.network[0].s3_vpce_id : null
}

module "security" {
  source = "../../modules/security"

  env                  = var.env
  account_id           = local.account_id
  data_lake_bucket_arn = module.data_lake.bucket_arn
  logs_bucket_id       = module.data_lake.logs_bucket_id
  logs_bucket_arn      = module.data_lake.logs_bucket_arn
  alert_email          = var.alert_email
  monthly_budget_usd   = var.monthly_budget_usd
  enable_guardduty     = var.enable_guardduty
  enable_config        = var.enable_config
}

module "analytics" {
  source = "../../modules/analytics"

  env                        = var.env
  region                     = var.region
  account_id                 = local.account_id
  data_lake_bucket_name      = module.data_lake.bucket_name
  data_lake_bucket_arn       = module.data_lake.bucket_arn
  athena_bytes_scanned_limit = var.athena_bytes_scanned_limit
}

module "warehouse" {
  source = "../../modules/warehouse"

  env                  = var.env
  enable_rds           = var.enable_rds && var.enable_network
  db_subnet_group_name = var.enable_network ? module.network[0].db_subnet_group_name : null
  db_security_group_id = var.enable_network ? module.network[0].db_security_group_id : null
  skip_final_snapshot  = false
  deletion_protection  = true
}

module "ingestion" {
  source = "../../modules/ingestion"

  env                   = var.env
  account_id            = local.account_id
  data_lake_bucket_id   = module.data_lake.bucket_id
  data_lake_bucket_name = module.data_lake.bucket_name
  data_lake_bucket_arn  = module.data_lake.bucket_arn
  ingest_schedule       = var.ingest_schedule
  sns_topic_arn         = module.security.sns_topic_arn
  glue_crawler_name     = module.analytics.glue_crawler_name
  glue_crawler_arn      = module.analytics.glue_crawler_arn
  private_subnet_ids    = var.enable_network ? module.network[0].private_subnet_ids : []
  security_group_ids    = var.enable_network ? [module.network[0].app_security_group_id] : []
  rds_secret_arn        = var.enable_rds ? module.warehouse.master_user_secret_arn : null
}

module "cicd" {
  source = "../../modules/cicd"

  env                = var.env
  github_repo        = var.github_repo
  enable_github_oidc = var.enable_github_oidc
}

output "data_lake_bucket" {
  value = module.data_lake.bucket_name
}

output "athena_workgroup" {
  value = module.analytics.athena_workgroup_name
}

output "glue_database" {
  value = module.analytics.glue_database_name
}

output "ingest_lambda" {
  value = module.ingestion.ingest_lambda_name
}

output "clean_lambda" {
  value = module.ingestion.clean_lambda_name
}

output "sns_topic_arn" {
  value = module.security.sns_topic_arn
}

output "reporting_role_arn" {
  value = module.ingestion.reporting_role_arn
}

output "github_plan_role_arn" {
  value = module.cicd.github_plan_role_arn
}

output "github_apply_role_arn" {
  value = module.cicd.github_apply_role_arn
}
