terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83"
    }
  }

  backend "s3" {
    bucket = "terraform-medium-api-notification"
    key    = "aws-user-group-jan-2025/state.tfstate"
  }
}

# Configure the AWS Provider
provider "aws" {}
