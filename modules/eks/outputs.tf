output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_external_dns_role_arn" {
  value = aws_iam_role.eks_external_dns_role.arn
}

output "eks_vault_unseal_role_arn" {
  value = aws_iam_role.eks_vault_role.arn
}

output "eks_kubeconfig_ca_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}

output "kms_key" {
  value = aws_kms_key.kms_key.key_id
}