resource "kubernetes_service" "account_service_svc" {
  metadata {
    name = "account-service-svc"
    labels = {
      app = "account-service"
    }
  }
  spec {
    port {
      name = "8080-8080"
      port = var.service_http_port
    }
    selector = {
      app = "account-service"
      role = "server"
    }
    type = "ClusterIP"
  }
} 

resource "kubernetes_deployment" "account_service_depl" {
  depends_on = [ 
    kubernetes_config_map.account_service_server_config, 
    kubernetes_secret.account_service_server_secret,
    kubernetes_stateful_set.account_service_db_ss,
    kubernetes_service.account_service_svc 
  ]
  metadata {
    name = "account-service-depl"
    labels = {
      app = "account-service"
    }
  }
  spec {
    replicas = var.service_replicas
    selector {
      match_labels = {
        app = "account-service"
        role = "server"
      }
    }
    template {
      metadata {
        labels = {
          app = "account-service"
          role = "server"
        }
      }
      spec {
        container {
          image = "iron2ron/account-service:latest"
          image_pull_policy = "Always"
          name = "account-service"
          port {
            container_port = var.service_http_port
          }
          env_from {
            config_map_ref {
              name = "account-service-server-config"
            }
          }
          env_from {
            secret_ref {
              name = "account-service-server-secret"
            }
          }
          resources {
            requests = {
              memory = "32Mi"
              cpu = "200m"
            }
            limits = {
              memory = "64Mi"
              cpu = "400m"
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