resource "kubernetes_service" "loan_service_svc" {
  metadata {
    name = "loan-service-svc"
    labels = {
      app = "loan-service"
    }
  }
  spec {
    port {
      name = "loan-service-port"
      port = var.service_http_port
    }
    selector = {
      app = "loan-service"
      role = "server"
    }
    type = "ClusterIP"
  }
} 

resource "kubernetes_deployment" "loan_service_depl" {
  depends_on = [ 
    kubernetes_config_map.loan_service_server_config, 
    kubernetes_secret.loan_service_server_secret,
    module.db,
    kubernetes_service.loan_service_svc 
  ]
  metadata {
    name = "loan-service-depl"
    labels = {
      app = "loan-service"
    }
  }
  spec {
    replicas = var.service_replicas
    selector {
      match_labels = {
        app = "loan-service"
        role = "server"
      }
    }
    template {
      metadata {
        labels = {
          app = "loan-service"
          role = "server"
        }
      }
      spec {
        container {
          image = var.service_server_image
          image_pull_policy = "Always"
          name = "loan-service"
          port {
            container_port = var.service_http_port
          }
          env_from {
            config_map_ref {
              name = "loan-service-server-config"
            }
          }
          env_from {
            secret_ref {
              name = "loan-service-server-secret"
            }
          }
          resources {
            requests = {
              memory = "64Mi"
              cpu = "300m"
            }
            limits = {
              memory = "128Mi"
              cpu = "500m"
            }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = var.service_http_port
            }
            initial_delay_seconds = 5
            period_seconds = 3
          }
        }
      }
    }
  }
}