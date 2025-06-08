variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "ami_id" {
  type    = string
  default = "ami-02660df44add5b55d" 
}
variable "tags" {
  type = map(string)
  default = {}
}
variable "subnets_ids" {
  type = list(string)
}
variable "instances_count" {
  type    = number
  default = 1
}
variable "sg_name" {
  type    = string
}
variable "ec2_name" {
  type    = string
  default = "my-ec2-instance"
}
variable "port_to_open" {
  type    = number
}
variable "adress_to_open" {
  type    = string
}
variable "vpc_id" {
  type = string
}
variable "key_name1" {
  type    = string
}