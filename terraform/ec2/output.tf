output "ec2_private_ips" {
  value = [for instance in aws_instance.ec2_instance : instance.private_ip]
}
output "ec2_ids" {
  value = [for instance in aws_instance.ec2_instance : instance.id]
}
output "ec2_names" {
  value = [for instance in aws_instance.ec2_instance : instance.tags["Name"]]
}