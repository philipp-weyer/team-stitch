terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.94.0"
    }

    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1.12"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
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
