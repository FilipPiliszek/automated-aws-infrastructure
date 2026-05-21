terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }

  }

  backend "s3" {
    bucket = "aas-storage-26"
    key    = "test/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}
