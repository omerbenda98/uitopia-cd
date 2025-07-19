# # Add prometheus-community Helm repository
# resource "helm_release" "kube_prometheus_stack" {
#   name       = "kube-prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace  = "monitoring"
#   version    = var.kube_prometheus_stack_version
#   create_namespace = true

#   # Values configuration
#   values = [
#     yamlencode({
#       # Prometheus configuration
#       prometheus = {
#         prometheusSpec = {
#           # Storage configuration for EKS
#           storageSpec = {
#             volumeClaimTemplate = {
#               spec = {
#                 storageClassName = "gp2"
#                 resources = {
#                   requests = {
#                     storage = var.prometheus_storage_size
#                   }
#                 }
#               }
#             }
#           }
          
#           # Retention settings
#           retention = var.prometheus_retention
#           retentionSize = var.prometheus_retention_size
          
#           # Resource limits
#           resources = {
#             limits = {
#               cpu    = var.prometheus_cpu_limit
#               memory = var.prometheus_memory_limit
#             }
#             requests = {
#               cpu    = var.prometheus_cpu_request
#               memory = var.prometheus_memory_request
#             }
#           }
          
#           # Selector configuration for better flexibility
#           serviceMonitorSelectorNilUsesHelmValues = false
#           podMonitorSelectorNilUsesHelmValues = false
#           ruleSelectorNilUsesHelmValues = false
#           scrapeConfigSelectorNilUsesHelmValues = false
#         }
#       }
      
#       # Alertmanager configuration
#       alertmanager = {
#         alertmanagerSpec = {
#           # Storage configuration
#           storage = {
#             volumeClaimTemplate = {
#               spec = {
#                 storageClassName = "gp2"
#                 resources = {
#                   requests = {
#                     storage = var.alertmanager_storage_size
#                   }
#                 }
#               }
#             }
#           }
          
#           # Resource limits
#           resources = {
#             limits = {
#               cpu    = var.alertmanager_cpu_limit
#               memory = var.alertmanager_memory_limit
#             }
#             requests = {
#               cpu    = var.alertmanager_cpu_request
#               memory = var.alertmanager_memory_request
#             }
#           }
          
#           # Retention configuration
#           retention = var.alertmanager_retention
#         }
#       }
      
#       # Grafana configuration
#       grafana = {
#         # Admin password (consider using AWS Secrets Manager in production)
#         adminPassword = var.grafana_admin_password
        
#         # Persistence configuration
#         persistence = {
#           enabled = var.grafana_persistence_enabled
#           storageClassName = "gp2"
#           size = var.grafana_storage_size
#         }
        
#         # Resource limits
#         resources = {
#           limits = {
#             cpu    = var.grafana_cpu_limit
#             memory = var.grafana_memory_limit
#           }
#           requests = {
#             cpu    = var.grafana_cpu_request
#             memory = var.grafana_memory_request
#           }
#         }
        
#         # Service configuration for LoadBalancer (optional)
#         service = {
#           type = var.grafana_service_type
#         }
        
#         # Enable additional plugins if needed
#         plugins = var.grafana_plugins
        
#         # Grafana configuration
#         "grafana.ini" = {
#           server = {
#             root_url = var.grafana_root_url
#           }
#           security = {
#             allow_embedding = true
#           }
#         }
#       }
      
#       # Node Exporter configuration
#       nodeExporter = {
#         enabled = true
#         hostPID = true
#         hostNetwork = true
#       }
      
#       # Kube State Metrics configuration
#       kubeStateMetrics = {
#         enabled = true
#       }
      
#       # Prometheus Operator configuration
#       prometheusOperator = {
#         enabled = true
        
#         # Resource limits for the operator
#         resources = {
#           limits = {
#             cpu    = "200m"
#             memory = "256Mi"
#           }
#           requests = {
#             cpu    = "100m"
#             memory = "128Mi"
#           }
#         }
        
#         # Admission webhooks configuration
#         admissionWebhooks = {
#           enabled = true
#           # Uncomment if you have issues with admission webhooks in EKS
#           # hostNetwork = true
#         }
#       }
#     })
#   ]

#   # Timeout for installation
#   timeout = 600

#   # Wait for all resources to be ready
#   wait = true

#   # Depend on EKS cluster and nodes being ready
#   depends_on = [
#     aws_eks_node_group.node_group,
#     aws_eks_addon.ebs_csi_driver,
#     null_resource.wait_for_cluster,
#   ]
# }


# resource "kubernetes_ingress_v1" "grafana" {
#   metadata {
#     name      = "grafana-ingress"
#     namespace = "monitoring"
#     annotations = {
#       "kubernetes.io/ingress.class"                    = "nginx"
#       "nginx.ingress.kubernetes.io/rewrite-target"     = "/"
#       "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
#       "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"  # If you have cert-manager
#       # Optional: Basic auth if you want extra security
#       # "nginx.ingress.kubernetes.io/auth-type"        = "basic"
#       # "nginx.ingress.kubernetes.io/auth-secret"      = "grafana-basic-auth"
#     }
#   }

#   spec {
#     # TLS configuration
#     tls {
#       hosts       = ["grafana.benda.wiki"]
#       secret_name = "grafana-tls"
#     }

#     rule {
#       host = "grafana.benda.wiki"
#       http {
#         path {
#           path      = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "kube-prometheus-stack-grafana"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [helm_release.kube_prometheus_stack]
# }


# # Optional: Create a LoadBalancer service for Alertmanager (for external access)
# # resource "kubernetes_service" "alertmanager_loadbalancer" {
# #   count = var.create_alertmanager_loadbalancer ? 1 : 0
  
# #   metadata {
# #     name      = "alertmanager-external"
# #     namespace = "monitoring"
# #     annotations = {
# #       "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
# #       "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
# #     }
# #   }
  
# #   spec {
# #     type = "LoadBalancer"
    
# #     port {
# #       port        = 9093
# #       target_port = 9093
# #       protocol    = "TCP"
# #     }
    
# #     selector = {
# #       "app.kubernetes.io/name" = "alertmanager"
# #       "alertmanager" = "kube-prometheus-stack-alertmanager"
# #     }
# #   }
  
# #   depends_on = [helm_release.kube_prometheus_stack]
# # }