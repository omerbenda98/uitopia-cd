resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace  = "argocd"
  create_namespace = true

  set = [
  {
    name  = "server.ingress.enabled"
    value = "true"
  },
  {
    name  = "server.ingress.ingressClassName"
    value = "nginx" # Ensure this matches your ingress controller class
  },

   {
    name  = "server.ingress.hostname"
    value = "argocd.benda.wiki" # Replace with your actual domain
  },
  {
      name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
      value = "HTTPS"
  },
  {
      name  = "server.metrics.enabled"
      value = "true"
  },
  {
      name  = "controller.metrics.enabled"
      value = "true"
  },
  {
      name  = "repoServer.metrics.enabled"
      value = "true"
  },
  {
      name  = "applicationSet.metrics.enabled"
      value = "true"
  }
  ]
  depends_on = [
  aws_eks_node_group.node_group,
  null_resource.wait_for_cluster,
  helm_release.ingress_nginx
]
}
data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}
output "argocd_admin_password" {
  value     = data.kubernetes_secret.argocd_admin_password.data["password"]
  sensitive = true
  
}

resource "kubernetes_manifest" "root-app" {
  manifest = yamldecode(file("../k8s/argocd/root-app.yaml"))
} 