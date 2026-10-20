terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  provider_meta "aws" {
    user_agent = ["AWS/1.0 abp-v2-dev/813578204325-v2:0.0.1"]
  }
}
