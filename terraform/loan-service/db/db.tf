resource "kubernetes_service" "loan_service_db_svc" {
  metadata {
    name = "loan-service-db-svc"
    labels = {
      app = "loan-service"
      role = "db"
    }
  }

  spec {
    port {
      port = var.db_port
      name = "mysql-default"
    } 
    cluster_ip = "None"
    selector = {
      app = "loan-service"
      role = "db"
    }
  }
}

resource "kubernetes_stateful_set" "loan_service_db_ss" {
  depends_on = [ 
    kubernetes_secret.loan_service_db_secret, 
    kubernetes_service.loan_service_db_svc,
    var.storage_class
  ]
  metadata {
    name = "loan-service-db-ss"
    labels = {
      app = "loan-service"
    }
  }

  spec {
    service_name = "loan-service-db-svc"
    selector {
      match_labels = {
        app = "loan-service"
      }
    }
    replicas = 1
    min_ready_seconds = 10
    template {
      metadata {
        labels = {
          app = "loan-service"
          role = "db"
        }
      }
      spec {
        termination_grace_period_seconds = 10
        container {
          name = "mysql"
          image = "mysql:9.2"
          port {
            container_port = var.db_port
            name = "mysql-default"
          }
          volume_mount {
            name = "loan-service-db-data"
            mount_path = "/var/lib/mysql"
          }
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "loan-service-db-secret"
                key = "db-password"
                optional = false
              }
            }
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "loan-service-db-data"
      }
      
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = {
            storage = var.db_storage_size
          }
        }
        storage_class_name = "ebs-sc"
      }
    }
  }
}

