# Simple S3 bucket configuration
# Creates buckets in dev and uat, but not in qa

variable "environment" {
  description = "Environment name"
  type        = string
}

locals {
  # Create bucket only in dev and uat, not in qa
  create_bucket = contains(["dev", "uat"], var.environment) ? 1 : 0
  
  name_prefix = "project-${var.environment}"
  
  common_tags = {
    Environment = var.environment
    Project     = "project-name"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "app_bucket" {
  count  = local.create_bucket
  bucket = "${local.name_prefix}-app-bucket"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-bucket"
  })
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = local.create_bucket == 1 ? aws_s3_bucket.app_bucket[0].bucket : "No bucket created for ${var.environment}"
} 