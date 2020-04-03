resource "aws_eks_cluster" "eks_cluster" {
  name     = join("-", [var.prefix, "eks"])
  role_arn = aws_iam_role.eks_role.arn
  tags     = var.tags
  version  = var.k8s_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Ensure that IAM policy attachments occur before and are deleted after EKS.
  # Otherwise, EKS will not be able to properly delete EKS-managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_role-AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  instance_types  = var.node_group_instance_types
  labels          = var.node_group_labels
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = var.subnet_ids
  tags            = var.tags

  remote_access {
    ec2_ssh_key = var.node_group_ssh_key
    source_security_group_ids = [aws_security_group.eks_cluster_node_group_remote_access_sg.id]
  }

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  # Ensure that IAM policy attachments occur before and are deleted after EKS.
  # Otherwise, EKS will not be able to properly delete EKS-managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_worker_role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_worker_role-AmazonEC2ContainerRegistryReadOnly,
  ]
}
