#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "this" {
  source = "../.."

  bucket_name = "abp-example-s3-bucket-object-lock-${random_id.suffix.hex}"

  # Object Lock requires versioning (enabled by default by this module) and
  # can only be turned on at bucket creation time.
  object_lock_enabled        = true
  object_lock_mode           = "GOVERNANCE"
  object_lock_retention_days = 30

  tags = {
    Example = "object-lock"
  }
}

# Random suffix keeps the example's bucket name globally unique across test runs.
resource "random_id" "suffix" {
  byte_length = 4
}
