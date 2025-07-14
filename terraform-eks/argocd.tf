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
  }
  ]
  depends_on = [
  aws_eks_node_group.node_group,
  null_resource.wait_for_cluster
]
}
data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}
output "argocd_admin_password" {
  value     = data.kubernetes_secret.argocd_admin_password.data["password"]
  sensitive = true
  
}

resource "kubernetes_manifest" "root-app" {
  manifest = yamldecode(file("../k8s/argocd/root-app.yaml"))
}