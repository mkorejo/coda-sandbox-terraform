#########################
######## Outputs ########
#########################

output "dev_private_bucket_id" {
  description = "Name of the dev private S3 bucket"
  value       = module.s3_dev_private.s3_bucket_id
}

output "dev_private_bucket_arn" {
  description = "ARN of the dev private S3 bucket"
  value       = module.s3_dev_private.s3_bucket_arn
}

output "dev_private_bucket_regional_domain_name" {
  description = "Region-specific domain name of the dev private S3 bucket"
  value       = module.s3_dev_private.s3_bucket_bucket_regional_domain_name
}

output "dev_logs_bucket_id" {
  description = "Name of the S3 access logging bucket"
  value       = module.s3_logs.s3_bucket_id
}
