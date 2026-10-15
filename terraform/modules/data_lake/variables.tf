variable "env" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in owner/name format for OIDC trust."
}

variable "enable_github_oidc" {
  type    = bool
  default = false
}

