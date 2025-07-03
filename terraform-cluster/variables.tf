variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "ami_id" {
  description = "Ubuntu 24.04 LTS AMI ID"
  type        = string
  # You'll need to find this for your region
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}
