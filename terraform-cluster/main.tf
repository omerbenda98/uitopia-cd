terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./vpc"
  aws_region = var.aws_region
  vpc_cidr = var.vpc_cidr
}

# Bastion Host in Public Subnet
module "bastion" {
  source = "./ec2"
  aws_region = var.aws_region
  key_name1 = var.key_name
  instance_type = "t3.micro"
  ami_id = var.ami_id
  subnets_ids = module.vpc.public_subnets
  instances_count = 1
  sg_name = "bastion_sg"
  sg_type = "basic"
  ec2_name = "k8s_bastion"
  port_to_open = 22
  adress_to_open = "0.0.0.0/0"  # SSH from anywhere
  vpc_id = module.vpc.vpc_id
  assign_public_ip = true  #
}

# K8s Master Node
module "k8s_master" {
  source = "./ec2"
  aws_region = var.aws_region
  key_name1 = var.key_name
  instance_type = "t3.medium"
  ami_id = var.ami_id
  subnets_ids = [module.vpc.private_subnets[0]]  # First private subnet
  instances_count = 1
  sg_name = "k8s_master_sg"
  sg_type = "k8s-master" 
  ec2_name = "k8s_master"
  port_to_open = 6443
  adress_to_open = module.vpc.vpc_cidr
  vpc_id = module.vpc.vpc_id
}

# K8s Worker Nodes
module "k8s_workers" {
  source = "./ec2"
  aws_region = var.aws_region
  key_name1 = var.key_name
  instance_type = "t3.small"
  ami_id = var.ami_id
  subnets_ids = module.vpc.private_subnets  # Spread across all private subnets
  instances_count = var.worker_count
  sg_name = "k8s_worker_sg"
  sg_type = "k8s-worker"
  ec2_name = "k8s_worker"
  port_to_open = 10250
  adress_to_open = module.vpc.vpc_cidr
  vpc_id = module.vpc.vpc_id
}
