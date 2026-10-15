variable "env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "data_lake_bucket_id" {
  type        = string
  description = "S3 bucket ID (name) for notifications."
}

variable "data_lake_bucket_name" {
  type = string
}

variable "data_lake_bucket_arn" {
  type = string
}

variable "ingest_schedule" {
  type        = string
  default     = "cron(0 6 ? * MON *)"
  description = "EventBridge schedule for weekly ingestion."
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "glue_crawler_name" {
  type        = string
  default     = null
  description = "Glue crawler to start on-demand after cleaning."
}

variable "glue_crawler_arn" {
  type    = string
  default = null
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Private subnets for VPC-attached clean Lambda."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security groups for VPC-attached clean Lambda."
}

variable "rds_secret_arn" {
  type        = string
  default     = null
  description = "Secrets Manager ARN for RDS credentials (optional)."
}
