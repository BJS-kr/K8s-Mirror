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
      port = 8080
    }
    selector = {
      app = "account-service"
      role = "server"
    }
    type = "ClusterIP"
  }
} 

resource "kubernetes_deployment" "account_service_depl" {
  metadata {
    name = "account-service-depl"
    labels = {
      app = "account-service"
    }
  }
  spec {
    replicas = var.account_service_replicas
    selector {
      match_labels = {
        app = "account-service"
      }
    }
    template {
      metadata {
        labels = {
          app = "account-service"
        }
      }
      spec {
        container {
          image = "iron2ron/account-service:latest"
          image_pull_policy = "Always"
          name = "account-service"
          port {
            container_port = 8080
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
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds = 3
          }
        }
      }
    }
  }
}
