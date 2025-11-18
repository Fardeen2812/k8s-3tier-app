terraform {
  backend "s3" {
    bucket       = "s3-backend-bucket-k8s-3tier-app"
    key          = "terraform-app/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
