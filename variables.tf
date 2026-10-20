variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique. If not provided, Terraform will assign a random, unique name."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to allow Terraform to destroy the bucket even if it still contains objects. Should be false in production."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Whether to enable versioning on the bucket."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm to use. Valid values are 'AES256' or 'aws:kms'."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be either 'AES256' or 'aws:kms'."
  }
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for server-side encryption. Required when sse_algorithm is 'aws:kms'; ignored otherwise."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}
