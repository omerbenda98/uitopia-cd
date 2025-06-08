variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "dns_address" {
  type    = string
}
variable "ami_id" {
  type    = string
  default = "ami-02660df44add5b55d" 
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "app_instance_count" {
  type    = number
  default = 1
}
variable "app_port" {
  type    = number
}
variable "app_name" {
  type    = string
  default = "my-app"
}
variable "sub_domain" {
  type    = string
  default = "app"
}
variable "key_name" {
  type    = string

}