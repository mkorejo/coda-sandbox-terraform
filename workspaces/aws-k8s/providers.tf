provider "aws" {
  version = "2.56.0"
  region  = local.region
}

# https://www.terraform.io/docs/providers/aws/d/eks_cluster_auth.html
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.sandbox_eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox_eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.sandbox_eks.token
    load_config_file       = false
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.sandbox_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.sandbox_eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.sandbox_eks.token
  load_config_file       = false
}