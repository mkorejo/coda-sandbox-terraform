#########################
########## S3 ###########
#########################

# Logging bucket — receives S3 access logs from the main bucket.
# Uses a bucket policy for log delivery (compatible with ACLs disabled).
module "s3_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.13.0"

  bucket = join("-", [local.prefix, "dev-logs"])
  tags   = merge(local.tags, { "Name" = join("-", [local.prefix, "dev-logs"]) })

  # Grant S3 log delivery write access via bucket policy
  attach_access_log_delivery_policy         = true
  access_log_delivery_policy_source_buckets = ["arn:aws:s3:::${join("-", [local.prefix, "dev-private"])}"]

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Private dev bucket
module "s3_dev_private" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.13.0"

  bucket = join("-", [local.prefix, "dev-private"])
  tags   = merge(local.tags, { "Name" = join("-", [local.prefix, "dev-private"]) })

  # Versioning
  versioning = {
    enabled = true
  }

  # Server-side encryption (SSE-S3 / AES-256)
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # Access logging — ship to the companion logging bucket
  logging = {
    target_bucket = module.s3_logs.s3_bucket_id
    target_prefix = "s3-access-logs/"
  }

  # Lifecycle rules
  lifecycle_rule = [
    {
      id      = "expire-noncurrent-versions"
      enabled = true

      noncurrent_version_expiration = {
        days = 90
      }
    },
    {
      id      = "expire-current-objects"
      enabled = true

      expiration = {
        days = 365
      }
    }
  ]
}
