#####################################################################################
# S3 bucket
#####################################################################################

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  # Object Lock can only be enabled at bucket creation time and cannot be
  # changed afterward without recreating the bucket.
  object_lock_enabled = var.object_lock_enabled

  tags = var.tags
}

# Block all public access by default. This is a security baseline and is not
# exposed as a variable so modules consuming this one cannot accidentally
# create a public bucket.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Disable ACLs in favor of bucket policies (bucket owner enforced).
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.sse_algorithm == "aws:kms" ? true : null
  }
}

#####################################################################################
# Object Lock (write-once-read-many)
#####################################################################################

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = var.object_lock_mode
      days  = var.object_lock_retention_days
      years = var.object_lock_retention_years
    }
  }

  depends_on = [aws_s3_bucket_versioning.this]

  lifecycle {
    precondition {
      condition     = var.versioning_enabled
      error_message = "object_lock_enabled requires versioning_enabled to be true."
    }

    precondition {
      condition     = (var.object_lock_retention_days != null) != (var.object_lock_retention_years != null)
      error_message = "object_lock_enabled requires exactly one of object_lock_retention_days or object_lock_retention_years to be set."
    }
  }
}
