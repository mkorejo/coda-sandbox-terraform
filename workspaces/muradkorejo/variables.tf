variable "aws_account_id" {
  type = string
}

variable "burpee_admin_credentials" {
  default = {
    "username" = "admin",
    "password" = "admin"
    "email"    = "admin@burpee.org"
  }
}

variable "burpee_default_db_password" {
  default = "burpee"
}

variable "burpee_iam_template_url" {
  type    = string
  default = "https://bsee-cloud-trial.s3-eu-west-1.amazonaws.com/2020.10.1-5542/iam-for-burp-suite-enterprise-edition.yaml"
}

variable "burpee_deployment_template_url" {
  type    = string
  default = "https://bsee-cloud-trial.s3-eu-west-1.amazonaws.com/2020.10.1-5542/burp-suite-enterprise-edition.yaml"
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
