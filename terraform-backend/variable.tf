variable "aws_region" {
  description = "The AWS region to deploy the resources to"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "The globally unique, lowercase S3 bucket name for Terraform state"
  type        = string
  default     = "s3-backend-bucket-k8s-3tier-app"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table to use for the Terraform backend"
  type        = string
  default     = "terraform-lock-table"
}
