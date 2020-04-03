variable "cluster_name" {
  type = string
  description = "Name of the EKS cluster for Kubernetes provider configuration. If blank, the module uses local.prefix to assume name (see providers.tf)."
  default = ""
}