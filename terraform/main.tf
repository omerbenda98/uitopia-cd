provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
  aws_region = var.aws_region
  vpc_cidr = var.vpc_cidr
}
module "app" {
  source = "./ec2"
  aws_region = var.aws_region
  key_name1 = var.key_name
  instance_type = "t2.micro"
  ami_id = var.ami_id
  subnets_ids = module.vpc.private_subnets
  instances_count = var.app_instance_count
  sg_name = "${var.app_name}_sg"
  ec2_name = "${var.app_name}_APP"
  port_to_open = var.app_port
  adress_to_open = module.vpc.vpc_cidr
  vpc_id = module.vpc.vpc_id
}

module "stage" {
  source = "./ec2"
  aws_region = var.aws_region
  instance_type = "t2.nano"
  key_name1 = var.key_name
  ami_id = var.ami_id
  subnets_ids = module.vpc.private_subnets
  instances_count = 1
  sg_name = "stage_sg"
  ec2_name = "${var.app_name}_stage"
  port_to_open = var.app_port
  adress_to_open = module.vpc.vpc_cidr
  vpc_id = module.vpc.vpc_id
}
module "app_lb" {
  source = "./alb"
  lb_name = "${var.app_name}-alb"
  vpc_id = module.vpc.vpc_id
  subnets_ids = module.vpc.public_subnets
  app_port = var.app_port
  instances_id =  module.app.ec2_ids
}
module "stage_lb" {
  source = "./alb"
  lb_name = "stage-${var.app_name}-alb"
  vpc_id = module.vpc.vpc_id
  subnets_ids = module.vpc.public_subnets
  app_port = var.app_port
  instances_id =  module.stage.ec2_ids
}
module "app_dns" {
  source = "./dns"
  dns_address = var.dns_address
  lb_dns_name = module.app_lb.alb_dns_name
  zone_id = module.app_lb.alb_hosted_zone_id
  sub_domain = var.sub_domain
}
module "stage_dns" {
  source = "./dns"
  dns_address = var.dns_address
  lb_dns_name = module.stage_lb.alb_dns_name
  zone_id = module.stage_lb.alb_hosted_zone_id
  sub_domain = "stage.${var.sub_domain}"
}