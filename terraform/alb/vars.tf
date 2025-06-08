variable "vpc_id" {
  type = string
}
variable "subnets_ids" {
  type = list(string)
}
variable "instances_id" {
  type = list(string)
}

variable "lb_name" {
  type    = string
  default = "my-app-alb"
}
variable "app_port" {
  type    = number
}