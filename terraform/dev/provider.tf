terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-file-periodic-care-package"
    key            = "periodic-care-package/import-boostrap/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_state_lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
