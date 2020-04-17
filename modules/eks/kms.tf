resource "aws_kms_key" "kms_key" {
  description             = join(" - ", [var.prefix, "EKS KMS"])
  deletion_window_in_days = 10

  tags = var.tags
}