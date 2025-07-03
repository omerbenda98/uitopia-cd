output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.bastion.ec2_public_ips
}

output "master_private_ip" {
  description = "Private IP of master node"
  value       = module.k8s_master.ec2_private_ips
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = module.k8s_workers.ec2_private_ips
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    bastion = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${module.bastion.ec2_public_ips[0]}"
    master = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${module.k8s_master.ec2_private_ips[0]}"
    workers = [for ip in module.k8s_workers.ec2_private_ips : "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${ip}"]
  }
}