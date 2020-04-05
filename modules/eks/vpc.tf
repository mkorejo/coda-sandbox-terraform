resource "aws_security_group" "eks_cluster_node_group_remote_access_sg" {
  name        = join("-", [aws_eks_cluster.eks_cluster.name, var.node_group_name, "remote-access"])
  description = "SSH access for EKS worker nodes"
  tags        = merge(var.tags, {
    "Name" = join("-", [aws_eks_cluster.eks_cluster.name, var.node_group_name, "remote-access"])
  })
  vpc_id      = var.vpc_id

  ingress {
    description = "tcp/22 inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
