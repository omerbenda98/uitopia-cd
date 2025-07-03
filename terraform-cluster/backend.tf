terraform {
  backend "s3" {
    bucket         = "uitopia-terraform-state"
    key            = "k8s-cluster/terraform.tfstate"  # Different key!
    region         = "us-east-1"
    dynamodb_table = "uitopia-terraform-locks"
    encrypt        = true
  }
}
