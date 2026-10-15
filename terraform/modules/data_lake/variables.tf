variable "region" {
  type    = string
  default = "af-south-1"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "owner" {
  type        = string
  description = "Owner tag and bucket name prefix."
}

variable "alert_email" {
  type        = string
  description = "Email for SNS and budget alerts."
}

variable "monthly_budget_usd" {
  type    = string
  default = "5"
}

variable "enable_network" {
  type    = bool
  default = false
}

variable "enable_rds" {
  type    = bool
  default = false
}

variable "enable_secrets_manager_endpoint" {
  type    = bool
  default = false
}

variable "enable_guardduty" {
  type    = bool
  default = false
}

variable "enable_config" {
  type    = bool
  default = false
}

variable "enable_github_oidc" {
  type    = bool
  default = false
}

variable "github_repo" {
  type        = string
  default     = "YOUR_GITHUB_USER/aws-public-health-data-lake"
  description = "GitHub repo for OIDC trust (owner/name)."
}

variable "ingest_schedule" {
  type    = string
  default = "cron(0 6 ? * MON *)"
}

variable "athena_bytes_scanned_limit" {
  type    = number
  default = 1073741824
}
