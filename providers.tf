terraform {
  required_version = "~> 1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"  # Relaxed to allow any 5.x.x version
    }

    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.6.3"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}