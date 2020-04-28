# Setup IAM Roles for Kubernetes Service Accounts
# https://www.terraform.io/docs/providers/aws/r/eks_cluster.html#enabling-iam-roles-for-service-accounts
# https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-technical-overview.html
data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    actions    = ["sts:AssumeRole", "sts:AssumeRoleWithWebIdentity"]
    effect     = "Allow"

    principals {
      identifiers = [var.aws_account_id]
      type        = "AWS"
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [join("", ["arn:aws:sts::", var.aws_account_id, ":assumed-role/", var.prefix, "-eks-external-dns/*"])]
    }
  }
}

data "aws_iam_policy_document" "service_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
      type        = "Federated"
    }

    condition {
      test     = "StringLike"
      variable = join(":", [replace(aws_iam_openid_connect_provider.eks_oidc.url, "https://", ""), "sub"])
      values   = ["system:serviceaccount:*:*"]
    }
  }
}

# https://github.com/terraform-providers/terraform-provider-aws/issues/10104
locals {
  eks-oidc-thumbprint = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.eks-oidc-thumbprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

# cert-manager and ExternalDNS
# https://cert-manager.io/docs/configuration/acme/dns01/route53/
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md
resource "aws_iam_role" "eks_external_dns_role" {
  name = join("-", [var.prefix, "eks-external-dns"])
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
}

resource "aws_iam_role_policy" "external_dns" {
  name   = join("-", [var.prefix, "eks-external-dns"])
  role   = aws_iam_role.eks_external_dns_role.name
  policy = jsonencode({
    Statement = [
      {
        Action   = ["route53:GetChange"],
        Effect   = "Allow",
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Action   = ["route53:ChangeResourceRecordSets"]
        Effect   = "Allow",
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

# Vault
# https://github.com/hashicorp/vault-guides/blob/master/operations/aws-kms-unseal/terraform-aws/instance-profile.tf
resource "aws_iam_role" "eks_vault_unseal_role" {
  name = join("-", [var.prefix, "eks-vault-unseal"])
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.service_account_assume_role_policy.json
}

resource "aws_iam_role_policy" "vault_kms_unseal" {
  name   = join("-", [var.prefix, "eks-vault-unseal"])
  role   = aws_iam_role.eks_vault_unseal_role.id
  policy = jsonencode({
    Statement = [{
      Action = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey",
      ]
      Effect = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}