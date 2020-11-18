resource "aws_iam_policy" "rancher_worker" {
  name        = "rancher-worker"
  description = "Allows etcd and worker nodes in Rancher-provisioned clusters to interact with EC2"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeInstances",
            "ec2:DescribeRegions",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage"
        ],
        "Resource": "*"
    }
]
}
EOF
}

resource "aws_iam_role" "rancher_worker" {
  name = "rancher-worker"
  tags = var.tags

  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_role_policy_attachment" "rancher_worker" {
  role       = aws_iam_role.rancher_worker.name
  policy_arn = aws_iam_policy.rancher_worker.arn
}

resource "aws_iam_instance_profile" "rancher_worker" {
  name = "rancher-worker-instance-profile"
  role = aws_iam_role.rancher_worker.name
}