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

variable "object_lock_enabled" {
  description = "Whether to enable S3 Object Lock (write-once-read-many) on the bucket. Can only be set at bucket creation time, requires versioning to be enabled, and requires exactly one of object_lock_retention_days or object_lock_retention_years to be set."
  type        = bool
  default     = false
}

variable "object_lock_mode" {
  description = "Default Object Lock retention mode applied to new object versions when object_lock_enabled is true. Valid values are 'GOVERNANCE' (lock can be overridden by users with special permissions) or 'COMPLIANCE' (lock cannot be overridden by anyone, including the root user)."
  type        = string
  default     = "GOVERNANCE"

  validation {
    condition     = contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_mode)
    error_message = "object_lock_mode must be either 'GOVERNANCE' or 'COMPLIANCE'."
  }
}

variable "object_lock_retention_days" {
  description = "Default Object Lock retention period, in days, applied to new object versions. Required (set exactly one of object_lock_retention_days / object_lock_retention_years) when object_lock_enabled is true; ignored otherwise."
  type        = number
  default     = null

  validation {
    condition     = var.object_lock_retention_days == null || var.object_lock_retention_days > 0
    error_message = "object_lock_retention_days must be a positive number when set."
  }
}

variable "object_lock_retention_years" {
  description = "Default Object Lock retention period, in years, applied to new object versions. Required (set exactly one of object_lock_retention_days / object_lock_retention_years) when object_lock_enabled is true; ignored otherwise."
  type        = number
  default     = null

  validation {
    condition     = var.object_lock_retention_years == null || var.object_lock_retention_years > 0
    error_message = "object_lock_retention_years must be a positive number when set."
  }
}
