output "eks_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_kubeconfig_ca_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority.0.data
}
