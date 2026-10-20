variable "env" {
  type = string
}

variable "account_id" {
  type = string
}

variable "data_lake_bucket_arn" {
  type = string
}

variable "logs_bucket_id" {
  type = string
}

variable "logs_bucket_arn" {
  type = string
}

variable "alert_email" {
  type        = string
  default     = null
  description = "Email for SNS alerts and budget notifications."
}

variable "monthly_budget_usd" {
  type    = string
  default = "5"
}

variable "enable_guardduty" {
  type    = bool
  default = false
}

variable "enable_config" {
  type    = bool
  default = false
}
