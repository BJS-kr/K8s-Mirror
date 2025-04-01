resource "kubernetes_ingress_v1" "account_service_ingress" {
  metadata {
    name = "account-service-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
    labels = {
      "app" = "account-service"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      
      http {
        path {
          path = "/account(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "account-service-svc"
              port {
                number = var.service_http_port
              }
            }
          }
        }
      }
    }
  }
}
