variable "env" {
  type = string
}

variable "enable_rds" {
  type    = bool
  default = false
}

variable "db_subnet_group_name" {
  type    = string
  default = null
}

variable "db_security_group_id" {
  type    = string
  default = null
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "max_allocated_storage" {
  type    = number
  default = 50
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "deletion_protection" {
  type    = bool
  default = false
}
