variable "env" {
  type = string
}

variable "owner" {
  type        = string
  description = "Owner tag and bucket name prefix."
}

variable "account_id" {
  type        = string
  description = "AWS account ID (suffix for globally unique bucket names)."
}

variable "s3_vpce_id" {
  type        = string
  default     = null
  description = "S3 gateway VPC endpoint ID; when set, curated/* GetObject requires traffic via this endpoint."
}
