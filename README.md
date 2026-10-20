<!-- BEGIN_TF_DOCS -->
# terraform-aws-813578204325-v2

<!-- Safe to remove this section once you familiar with the module scafolding architecture -->
## Getting Started (Module Authors)

New to this repo? See the [Author Quick-Start Guide](AUTHOR\_GUIDE.md) for a step-by-step walkthrough — from personalizing the template to your first release.

<!-- Update the title and description above with your module name and a brief overview -->

This module creates a secure S3 bucket with public access blocked, bucket-owner-enforced
ownership (no ACLs), versioning, and server-side encryption enabled by default.

## Architecture

<!-- Add an architecture diagram reference here -->
<!-- ![Architecture](./images/architecture.png) -->

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 1.7.0

## Usage

```hcl
module "example" {
  source  = "abp-v2-dev/813578204325-v2/aws"
  version = ">= 0.0.1"

  bucket_name = "my-unique-bucket-name"

  tags = {
    Environment = "dev"
  }
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for local development setup, pre-commit hooks, CI/CD configuration, and functional test setup.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket. Must be globally unique. If not provided, Terraform will assign a random, unique name. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Whether to allow Terraform to destroy the bucket even if it still contains objects. Should be false in production. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key to use for server-side encryption. Required when sse\_algorithm is 'aws:kms'; ignored otherwise. | `string` | `null` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | Whether to enable S3 Object Lock (write-once-read-many) on the bucket. Can only be set at bucket creation time, requires versioning to be enabled, and requires exactly one of object\_lock\_retention\_days or object\_lock\_retention\_years to be set. | `bool` | `false` | no |
| <a name="input_object_lock_mode"></a> [object\_lock\_mode](#input\_object\_lock\_mode) | Default Object Lock retention mode applied to new object versions when object\_lock\_enabled is true. Valid values are 'GOVERNANCE' (lock can be overridden by users with special permissions) or 'COMPLIANCE' (lock cannot be overridden by anyone, including the root user). | `string` | `"GOVERNANCE"` | no |
| <a name="input_object_lock_retention_days"></a> [object\_lock\_retention\_days](#input\_object\_lock\_retention\_days) | Default Object Lock retention period, in days, applied to new object versions. Required (set exactly one of object\_lock\_retention\_days / object\_lock\_retention\_years) when object\_lock\_enabled is true; ignored otherwise. | `number` | `null` | no |
| <a name="input_object_lock_retention_years"></a> [object\_lock\_retention\_years](#input\_object\_lock\_retention\_years) | Default Object Lock retention period, in years, applied to new object versions. Required (set exactly one of object\_lock\_retention\_days / object\_lock\_retention\_years) when object\_lock\_enabled is true; ignored otherwise. | `number` | `null` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | Server-side encryption algorithm to use. Valid values are 'AES256' or 'aws:kms'. | `string` | `"AES256"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the bucket. | `map(string)` | `{}` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | Whether to enable versioning on the bucket. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The name (ID) of the bucket. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. |
| <a name="output_object_lock_enabled"></a> [object\_lock\_enabled](#output\_object\_lock\_enabled) | Whether S3 Object Lock (write-once-read-many) is enabled on the bucket. |
<!-- END_TF_DOCS -->