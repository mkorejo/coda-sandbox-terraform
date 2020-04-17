resource "aws_kms_key" "kms_key" {
  description             = join(" - ", [var.prefix, "EKS KMS"])
  deletion_window_in_days = 10

  tags = var.tags
}

resource "aws_kms_alias" "kms_alias" {
  name          = join("", ["alias/", var.prefix, "-eks"])
  target_key_id = aws_kms_key.kms_key.key_id
}