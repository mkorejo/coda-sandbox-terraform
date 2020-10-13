# Specify the name of our EKS cluster, our KMS key, our Route53 Hosted Zone, etc.
data "aws_acm_certificate" "eks_elb_cert" {
  domain   = "*.devops.coda.run"
  statuses = ["ISSUED"]
}

data "aws_eks_cluster" "sandbox_eks" {
  name = join("-", [local.prefix, "eks"])
}

data "aws_eks_cluster_auth" "sandbox_eks" {
  name = join("-", [local.prefix, "eks"])
}

data "aws_iam_role" "eks_external_dns_role" {
  name = join("-", [local.prefix, "eks-external-dns"])
}

data "aws_kms_alias" "eks_kms_key" {
  name = join("", ["alias/", local.prefix, "-eks"])
}

data "aws_route53_zone" "hosted_zone" {
  name = "devops.coda.run."
}