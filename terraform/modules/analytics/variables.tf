variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "data_lake_bucket_name" {
  type = string
}

variable "data_lake_bucket_arn" {
  type = string
}

variable "athena_bytes_scanned_limit" {
  type        = number
  default     = 1073741824 # 1 GB per query
  description = "Max bytes scanned per Athena query (cost guardrail)."
}
