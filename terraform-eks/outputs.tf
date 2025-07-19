# outputs.tf - Clean and essential outputs only

# ======================
# CLUSTER ESSENTIALS
# ======================
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.cluster.version
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${aws_eks_cluster.cluster.name}"
}

# ======================
# ARGOCD ACCESS
# ======================


output "argocd_access" {
  description = "How to access ArgoCD"
  value       = "kubectl port-forward svc/argocd-server 8080:443 -n argocd"
}

# ======================
# MONITORING ACCESS
# ======================
output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = var.grafana_admin_password
  sensitive   = true
}

# output "grafana_url" {
#   description = "Grafana external URL"
#   value       = var.grafana_service_type == "LoadBalancer" ? 
#     "Check: kubectl get svc kube-prometheus-stack-grafana -n monitoring" : 
#     "Use: kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring"
# }

output "prometheus_access" {
  description = "How to access Prometheus"
  value       = "kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring"
}

# ======================
# QUICK ACCESS COMMANDS
# ======================
output "quick_access" {
  description = "Essential commands for daily use"
  value = {
    grafana     = "kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring"
    prometheus  = "kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n monitoring"
    argocd      = "kubectl port-forward svc/argocd-server 8080:443 -n argocd"
    get_pods    = "kubectl get pods -A"
    get_nodes   = "kubectl get nodes"
  }
}