# Storage Class
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }
  storage_provisioner    = "kubernetes.io/no-provisioner"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true
  mount_options          = ["rw"]
  volume_binding_mode    = "WaitForFirstConsumer"
}

# NGINX Gateway Fabric
# resource "helm_release" "nginx_gateway_fabric" {
#   name             = "nginx-gateway-fabric"
#   repository       = "https://helm.nginx.com/stable"
#   chart            = "nginx-gateway-fabric"
#   version          = "1.6.2"
#   namespace        = "nginx-gateway"
#   create_namespace = true

#   set {
#     name  = "controller.service.type"
#     value = "LoadBalancer"
#   }
# }

# # Gateway API Resources
# resource "kubernetes_manifest" "gateway_class" {
#   manifest = {
#     apiVersion = "gateway.networking.k8s.io/v1beta1"
#     kind       = "GatewayClass"
#     metadata = {
#       name = "nginx"
#     }
#     spec = {
#       controllerName = "nginx.org/gateway-controller"
#     }
#   }
# }

# resource "kubernetes_manifest" "gateway" {
#   manifest = {
#     apiVersion = "gateway.networking.k8s.io/v1beta1"
#     kind       = "Gateway"
#     metadata = {
#       name      = "msa-gateway"
#       namespace = "nginx-gateway"
#     }
#     spec = {
#       gatewayClassName = "nginx"
#       listeners = [
#         {
#           name     = "http"
#           port     = 80
#           protocol = "HTTP"
#           allowedRoutes = {
#             namespaces = {
#               from = "All"
#             }
#           }
#         }
#       ]
#     }
#   }
# }

# # Service Routes
# resource "kubernetes_manifest" "account_route" {
#   manifest = {
#     apiVersion = "gateway.networking.k8s.io/v1beta1"
#     kind       = "HTTPRoute"
#     metadata = {
#       name      = "account-route"
#       namespace = "default"
#     }
#     spec = {
#       parentRefs = [
#         {
#           name      = "msa-gateway"
#           namespace = "nginx-gateway"
#         }
#       ]
#       hostnames = [var.gateway_hostname]
#       rules = [
#         {
#           matches = [
#             {
#               path = {
#                 type  = "PathPrefix"
#                 value = "/account"
#               }
#             }
#           ]
#           backendRefs = [
#             {
#               name = "account-service"
#               port = 80
#             }
#           ]
#         }
#       ]
#     }
#   }
# }

# resource "kubernetes_manifest" "loan_route" {
#   manifest = {
#     apiVersion = "gateway.networking.k8s.io/v1beta1"
#     kind       = "HTTPRoute"
#     metadata = {
#       name      = "loan-route"
#       namespace = "default"
#     }
#     spec = {
#       parentRefs = [
#         {
#           name      = "msa-gateway"
#           namespace = "nginx-gateway"
#         }
#       ]
#       hostnames = [var.gateway_hostname]
#       rules = [
#         {
#           matches = [
#             {
#               path = {
#                 type  = "PathPrefix"
#                 value = "/loan"
#               }
#             }
#           ]
#           backendRefs = [
#             {
#               name = "loan-service"
#               port = 80
#             }
#           ]
#         }
#       ]
#     }
#   }
# }

# # Metrics Server
# resource "helm_release" "metrics_server" {
#   name             = "metrics-server"
#   repository       = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart            = "metrics-server"
#   version          = "6.3.8"
#   namespace        = "kube-system"
#   create_namespace = false

#   set {
#     name  = "args"
#     value = jsonencode(["--kubelet-insecure-tls"])
#   }
# } 