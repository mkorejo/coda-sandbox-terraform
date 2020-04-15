data "aws_eks_cluster" "sandbox_eks" {
  name = local.cluster_name
}

data "aws_eks_cluster_auth" "sandbox_eks" {
  name = local.cluster_name
}

data "aws_iam_role" "eks_external_dns_role" {
  name = local.eks_external_dns_role_name
}