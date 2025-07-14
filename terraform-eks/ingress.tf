# Install NGINX Ingress Controller using Helm
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  # Use the latest version or specify a version
  version = var.ingress_nginx_version # Add this variable to your variables.tf

  # Configure the ingress controller
#   set = [
#     {
#       name  = "controller.service.type"
#       value = "LoadBalancer"
#     },
#     {
#       name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
#       value = "internet-facing"
#     },
#     {
#       name  = "controller.config.ssl-redirect"
#       value = "false"
#     },
#     {
#       name  = "controller.admissionWebhooks.enabled"
#       value = "false"
#     }
#   ]

 depends_on = [
    aws_eks_node_group.node_group,
    null_resource.wait_for_cluster,
    helm_release.ingress_nginx
  ]

}