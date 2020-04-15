variable "aws_hosted_zone_id" {
  type = string
  description = "Hosted Zone ID for ExternalDNS and cert-manager"
}

variable "cluster_name" {
  type = string
  description = "Name of the EKS cluster for Kubernetes provider configuration. If blank, the module uses local.prefix to assume name (see locals.tf)."
  default = ""
}

variable "eks_external_dns_role_name" {
  type = string
  description = "AWS IAM Role ARN for ExternalDNS service account. If blank, the module uses local.prefix to assume name (see locals.tf)."
  default = ""
}