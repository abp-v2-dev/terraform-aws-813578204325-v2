# Define example-specific outputs here.

output "bucket_id" {
  description = "The name (ID) of the created bucket."
  value       = module.this.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the created bucket."
  value       = module.this.bucket_arn
}

output "object_lock_enabled" {
  description = "Whether S3 Object Lock is enabled on the created bucket."
  value       = module.this.object_lock_enabled
}
