resource "kubernetes_secret" "account_service_db_secret" {
  metadata {
    name = "account-service-db-secret"
  }
  data = {
    "db-password" = var.db_password
  }
}

resource "kubernetes_service" "account_service_db_svc" {
  metadata {
    name = "account-service-db-svc"
    labels = {
      app = "account-service"
      role = "db"
    }
  }

  spec {
    port {
      port = var.db_port
      name = "pg-default"
    } 
    cluster_ip = "None"
    selector = {
      app = "account-service"
      role = "db"
    }
  }
}


resource "kubernetes_stateful_set" "account_service_db_ss" {
  depends_on = [ 
    kubernetes_secret.account_service_db_secret, 
    kubernetes_service.account_service_db_svc,
    kubernetes_storage_class.ebs_sc
  ]
  metadata {
    name = "account-service-db-ss"
    labels = {
      app = "account-service"
    }
  }

  spec {
    service_name = "account-service-db-svc"
    selector {
      match_labels = {
        app = "account-service"
      }
    }
    replicas = 1
    min_ready_seconds = 10
    template {
      metadata {
        labels = {
          app = "account-service"
          role = "db"
        }
      }
      spec {
        termination_grace_period_seconds = 10
        container {
          name = "pg"
          image = "postgres:17.4-alpine"
          port {
            container_port = var.db_port
            name = "pg-default"
          }
          volume_mount {
            name = "account-service-db-data"
            mount_path = "/var/lib/postgresql/data"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = "account-service-db-secret"
                key = "db-password"
                optional = false
              }
            }
          }
          env {
            name = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "account-service-db-data"
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

resource "kubernetes_network_policy" "account_service_db_network_policy" {
  metadata {
    name = "account-service-db-network-policy"
  }
  spec {
    pod_selector {
      match_labels = {
        app = "account-service"
        role = "db"
      }
    }
    policy_types = ["Ingress", "Egress"]
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "account-service"
            role = "server"
          }
        }
      }
      ports {
        port = var.db_port
        protocol = "TCP"
      }
    }

    egress {
      to {
        pod_selector {
          match_labels = {
            app = "account-service"
            role = "server"
          }
        }
      }
    }
  }
}