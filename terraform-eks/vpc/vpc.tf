provider "aws" {
  region = var.aws_region
}
locals {
  vpc_cidr = "10.0.0.0/16"
  }
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "MyApp_VPC"
  cidr = local.vpc_cidr
  azs                 = data.aws_availability_zones.available.names
  private_subnets     = [for k, v in data.aws_availability_zones.available.names : 
                        cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets      = [for k, v in data.aws_availability_zones.available.names : 
                        cidrsubnet(local.vpc_cidr, 8, k + 6)]
  database_subnets    = [for k, v in data.aws_availability_zones.available.names : 
                        cidrsubnet(local.vpc_cidr, 8, k + 12)]

  private_subnet_names = [for k, v in data.aws_availability_zones.available.names : "Private-${k+1}"]
  public_subnet_names  = [for k, v in data.aws_availability_zones.available.names : "Public-${k+1}"]
  database_subnet_names = [for k, v in data.aws_availability_zones.available.names : "Database-${k+1}"]
    enable_nat_gateway   = true
    single_nat_gateway   = true
}