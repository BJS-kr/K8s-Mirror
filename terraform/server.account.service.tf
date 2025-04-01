resource "kubernetes_config_map" "account_service_server_config" {
  metadata {
    name = "account-service-server-config"
  }
  data = {
    DB_HOST = var.account_db_host
    HTTP_PORT = var.account_service_http_port
    LOAN_SERVICE_ADDR = "http://loan-service-svc:8081"
  }
}

resource "kubernetes_secret" "account_service_server_secret" {
  metadata {
    name = "account-service-server-secret"
  }
  data = {
    DB_NAME = var.account_db_name
    DB_PASSWORD = var.account_db_password
    DB_PORT = var.account_db_port
    DB_USER = var.account_db_user
  }
}

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
      port = var.account_service_http_port
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
    replicas = var.account_service_replicas
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
            container_port = var.account_service_http_port
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
              port = var.account_service_http_port
            }
            initial_delay_seconds = 5
            period_seconds = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "account_service_hpa" {
  metadata {
    name = "account-service-hpa"
  }
  spec {
    max_replicas = var.account_service_max_replicas
    min_replicas = var.account_service_min_replicas 
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "account-service-depl"
    }
    target_cpu_utilization_percentage = var.account_service_target_cpu_utilization_percentage
  }
}

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
                number = var.account_service_http_port
              }
            }
          }
        }
      }
    }
  }
}



