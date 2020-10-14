variable "flux_config_repo" {
  type = string
  description = <<-EOT
    Git URL for Flux configuration repository
  EOT
  default = "git@github.com:mkorejo/helm-operator-get-started.git"
}