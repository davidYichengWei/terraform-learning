terraform {
    required_version = ">= 0.12.0"
    backend "s3" {
        bucket = "myapp-terraform-state-bkt"
        key = "terraform-eks.tfstate"
        region = "us-east-1"
    }
}