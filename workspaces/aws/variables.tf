variable "aws_account_id" {
  type = string
}

variable "features" {
  type = map(bool)
  description = "List of features/resources to enable"
  default = {
    "eks"         = true
    "psql"        = true
    "rancher-iam" = true
  }
}

variable "rds_skip_final_snapshot" {
  type    = bool
  default = true
}

variable "rds_master_username" {
  default = "foo"
}

variable "rds_master_password" {
  default = "foobarbaz"
}
