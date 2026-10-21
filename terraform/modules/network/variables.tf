variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "enable_rds" {
  type        = bool
  default     = false
  description = "Create RDS subnet group. Set false in dev to save cost."
}

variable "enable_secrets_manager_endpoint" {
  type        = bool
  default     = false
  description = "Enable Secrets Manager VPC interface endpoint for private Lambda."
}
