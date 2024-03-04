terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.12"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}
