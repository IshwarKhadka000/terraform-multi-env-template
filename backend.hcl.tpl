# Backend configuration template for Terraform
# Only ENV is dynamically injected from GitHub variables

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "${ENV}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
  }
} 