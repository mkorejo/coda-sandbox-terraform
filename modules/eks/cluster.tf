resource "aws_eks_cluster" "eks_cluster" {
  name     = join("-", [var.prefix, "eks"])
  role_arn = aws_iam_role.eks_role.arn
  tags     = var.tags
  version  = var.k8s_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_role-AmazonEKSServicePolicy,
  ]
}
