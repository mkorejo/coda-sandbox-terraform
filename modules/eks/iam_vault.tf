data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vault_kms_unseal" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_role" "eks_vault_unseal_role" {
  name = join("-", [var.prefix, "eks-vault-unseal"])
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.service_account_assume_role_policy.json
}

resource "aws_iam_role_policy" "vault_kms_unseal" {
  name   = join("-", [var.prefix, "eks-vault-unseal"])
  role   = aws_iam_role.eks_vault_unseal_role.id
  policy = data.aws_iam_policy_document.vault_kms_unseal.json
}