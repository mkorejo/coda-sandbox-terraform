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