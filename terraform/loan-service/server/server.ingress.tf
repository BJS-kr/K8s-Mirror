resource "kubernetes_ingress_v1" "loan_service_ingress" {
  metadata {
    name = "loan-service-ingress"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
    labels = {
      "app" = "loan-service"
    }
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      
      http {
        path {
          path = "/loan(/|$)(.*)"
          path_type = "Prefix"
          backend {
            service {
              name = "loan-service-svc"
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
