terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  provider_meta "aws" {
    user_agent = ["AWS/1.0 __ORG_NAME__/__MODULE_NAME__:__VERSION__"]
  }
}
