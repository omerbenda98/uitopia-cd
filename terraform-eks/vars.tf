variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "uitopia-eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

# VPC Variables
variable "create_vpc" {
  description = "Whether to create a new VPC or use existing one"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "Existing VPC ID (if create_vpc is false)"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Existing private subnet IDs (if create_vpc is false)"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Existing public subnet IDs (if create_vpc is false)"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "single_nat_gateway" {
  description = "Should be true to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

# EKS Cluster Variables
variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

# Node Group Variables
variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_unavailable" {
  description = "Desired max number of unavailable worker nodes during node group update"
  type        = number
  default     = 1
}

# Add-ons
variable "ebs_csi_driver_version" {
  description = "Version of the EBS CSI driver addon"
  type        = string
  default     = "v1.24.0-eksbuild.1"
}

variable "install_nginx_ingress" {
  description = "Whether to install NGINX Ingress Controller"
  type        = bool
  default     = true
}

# DNS Variables (for using your existing DNS module)
variable "domain_name" {
  description = "Domain name for the application (e.g., benda.wiki)"
  type        = string
  default     = ""
}

variable "create_dns_records" {
  description = "Whether to create DNS records"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "uitopia"
    ManagedBy   = "terraform"
    TestRun       = "cd-pipeline-test"  # Add this new tag
    LastModified  = "2025-01-06"        # Add this new tag
  }
}

# Environment-specific variables
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "enable_cluster_autoscaler" {
  description = "Whether to enable cluster autoscaler"
  type        = bool
  default     = false
}

variable "enable_metrics_server" {
  description = "Whether to enable metrics server"
  type        = bool
  default     = true
}


# Add these to your existing variables.tf file

variable "ingress_nginx_version" {
  description = "Version of the ingress-nginx Helm chart"
  type        = string
  default     = "4.8.3"  # Use a specific version for reproducibility
}

# If you want to make the ingress controller installation optional
variable "install_ingress_nginx" {
  description = "Whether to install the NGINX Ingress Controller"
  type        = bool
  default     = true
}

# External-DNS configuration variables
variable "external_dns_version" {
  description = "Version of the external-dns Helm chart"
  type        = string
  default     = "1.14.3"
}

variable "external_dns_domain_filters" {
  description = "List of domains that external-dns should manage (e.g., ['example.com', 'subdomain.example.com'])"
  type        = list(string)
  default     = null  # Set to null to manage all domains, or specify specific domains
}


variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "url_site" {
  description = "Domain name"
  type        = string
  default     = "benda.wiki" # Replace with your actual domain
  
}
# monitoring-variables.tf - Variables for monitoring stack

# Kube Prometheus Stack version
variable "kube_prometheus_stack_version" {
  description = "Version of kube-prometheus-stack Helm chart"
  type        = string
  default     = "75.10.0"  # Latest stable version as of 2025
}

# Prometheus configuration
variable "prometheus_storage_size" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "50Gi"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "30d"
}

variable "prometheus_retention_size" {
  description = "Prometheus data retention size"
  type        = string
  default     = "45GiB"
}

variable "prometheus_cpu_limit" {
  description = "CPU limit for Prometheus"
  type        = string
  default     = "2000m"
}

variable "prometheus_memory_limit" {
  description = "Memory limit for Prometheus"
  type        = string
  default     = "8Gi"
}

variable "prometheus_cpu_request" {
  description = "CPU request for Prometheus"
  type        = string
  default     = "1000m"
}

variable "prometheus_memory_request" {
  description = "Memory request for Prometheus"
  type        = string
  default     = "4Gi"
}

# Alertmanager configuration
variable "alertmanager_storage_size" {
  description = "Storage size for Alertmanager"
  type        = string
  default     = "5Gi"
}

variable "alertmanager_retention" {
  description = "Alertmanager data retention period"
  type        = string
  default     = "120h"
}

variable "alertmanager_cpu_limit" {
  description = "CPU limit for Alertmanager"
  type        = string
  default     = "100m"
}

variable "alertmanager_memory_limit" {
  description = "Memory limit for Alertmanager"
  type        = string
  default     = "256Mi"
}

variable "alertmanager_cpu_request" {
  description = "CPU request for Alertmanager"
  type        = string
  default     = "50m"
}

variable "alertmanager_memory_request" {
  description = "Memory request for Alertmanager"
  type        = string
  default     = "128Mi"
}

# Grafana configuration
variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "grafana_persistence_enabled" {
  description = "Enable persistence for Grafana"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Storage size for Grafana"
  type        = string
  default     = "10Gi"
}


variable "grafana_cpu_limit" {
  description = "CPU limit for Grafana"
  type        = string
  default     = "200m"
}

variable "grafana_memory_limit" {
  description = "Memory limit for Grafana"
  type        = string
  default     = "256Mi"
}

variable "grafana_cpu_request" {
  description = "CPU request for Grafana"
  type        = string
  default     = "100m"
}

variable "grafana_memory_request" {
  description = "Memory request for Grafana"
  type        = string
  default     = "128Mi"
}

variable "grafana_plugins" {
  description = "List of Grafana plugins to install"
  type        = list(string)
  default     = []
}

variable "grafana_root_url" {
  description = "Root URL for Grafana"
  type        = string
  default     = ""
}

# DNS and Ingress variables
variable "create_grafana_dns_record" {
  description = "Create DNS A record for Grafana"
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for benda.wiki"
  type        = string
  default     = "Z01359572SN6H2QBYEJGW"  # Add your hosted zone ID
}

variable "aws_elb_zone_id" {
  description = "AWS ELB zone ID for your region"
  type        = string
  default     = "Z35SXDOTRQ7X7K"  # us-east-1, change if different region
}

# Update your existing grafana_service_type default
variable "grafana_service_type" {
  description = "Service type for Grafana"
  type        = string
  default     = "ClusterIP"  # Changed from "LoadBalancer"
  
  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.grafana_service_type)
    error_message = "Grafana service type must be ClusterIP, NodePort, or LoadBalancer."
  }
}