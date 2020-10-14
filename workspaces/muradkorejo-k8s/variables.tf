variable "flux_config_git_url" {
  type = string
  description = <<-EOT
    Git URL for Flux configuration repository
  EOT
  default = "git@github.com:mkorejo/helm-operator-get-started.git"
}

variable "flux_config_git_paths" {
  type = list(string)
  description = <<-EOT
    One or more paths in Git repository (flux_config_git_url) to locate
    Kubernetes manifests.
  EOT
  default = null
}