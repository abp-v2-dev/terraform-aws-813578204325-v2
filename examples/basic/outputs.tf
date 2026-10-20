# Define example-specific outputs here.

output "bucket_id" {
  description = "The name (ID) of the created bucket."
  value       = module.this.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the created bucket."
  value       = module.this.bucket_arn
}
