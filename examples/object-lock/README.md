<!-- BEGIN_TF_DOCS -->
# Object Lock (Write-Once-Read-Many) Example

This example demonstrates enabling S3 Object Lock on the bucket with a default
retention period, so new object versions cannot be deleted or overwritten
until the retention period expires.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the created bucket. |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The name (ID) of the created bucket. |
| <a name="output_object_lock_enabled"></a> [object\_lock\_enabled](#output\_object\_lock\_enabled) | Whether S3 Object Lock is enabled on the created bucket. |
<!-- END_TF_DOCS -->