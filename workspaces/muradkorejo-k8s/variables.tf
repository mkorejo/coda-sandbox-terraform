# Query AWS resources for future reference
data "aws_eks_cluster" "sandbox_eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "sandbox_eks" {
  name = local.cluster_name
}

data "aws_iam_role" "eks_external_dns_role" {
  name = local.eks_external_dns_role_name
}

locals {
  prefix = "muradkorejo"
  region = "us-east-1"

  tags = map(
    "Owner",       "Murad Korejo",
    "Owner Email", "murad.korejo@coda.global",
    "Managed By",  "Terraform",
    "Source",      "https://github.com/mkorejo/coda-sandbox-terraform"
  )

  cluster_name               = var.cluster_name != "" ? var.cluster_name : join("-", [local.prefix, "eks"])
  eks_external_dns_role_name = var.eks_external_dns_role_name != "" ? var.eks_external_dns_role_name : join("-", [local.prefix, "eks-external-dns-role"])
}

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