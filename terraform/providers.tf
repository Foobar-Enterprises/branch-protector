terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  access_key = "AKIAYLU3563IOMPDJEGJ"
  secret_key = "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"
}
