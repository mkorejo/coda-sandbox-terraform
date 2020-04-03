data "aws_eks_cluster" "sandbox_eks" {
  name = var.cluster_name != "" ? var.cluster_name : join("-", [local.prefix, "eks"])
}

data "aws_eks_cluster_auth" "sandbox_eks" {
  name = var.cluster_name != "" ? var.cluster_name : join("-", [local.prefix, "eks"])
}

provider "aws" {
  version = "2.56.0"

  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.sandbox_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox_eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.sandbox_eks.token
  load_config_file       = false
}