#########################
########## S3 ###########
#########################

# Logging bucket — receives S3 access logs from the main bucket
resource "aws_s3_bucket" "dev_logs" {
  bucket = join("-", [local.prefix, "dev-logs"])
  acl    = "log-delivery-write"
  tags   = merge(local.tags, {"Name" = join("-", [local.prefix, "dev-logs"])})

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "dev_logs" {
  bucket                  = aws_s3_bucket.dev_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Private dev bucket
resource "aws_s3_bucket" "dev_private" {
  bucket = join("-", [local.prefix, "dev-private"])
  acl    = "private"
  tags   = merge(local.tags, {"Name" = join("-", [local.prefix, "dev-private"])})

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.dev_logs.id
    target_prefix = "s3-access-logs/"
  }

  # Expire non-current (versioned) objects after 90 days
  lifecycle_rule {
    id      = "expire-noncurrent-versions"
    enabled = true

    noncurrent_version_expiration {
      days = 90
    }
  }

  # Expire current objects after 365 days
  lifecycle_rule {
    id      = "expire-current-objects"
    enabled = true

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "dev_private" {
  bucket                  = aws_s3_bucket.dev_private.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################
######### Outputs #######
#########################

output "dev_private_bucket_name" {
  description = "Name of the dev private S3 bucket"
  value       = aws_s3_bucket.dev_private.id
}

output "dev_private_bucket_arn" {
  description = "ARN of the dev private S3 bucket"
  value       = aws_s3_bucket.dev_private.arn
}

output "dev_logs_bucket_name" {
  description = "Name of the S3 access logging bucket"
  value       = aws_s3_bucket.dev_logs.id
}
