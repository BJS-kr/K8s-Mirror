resource "kubernetes_secret" "account_service_db_secret" {
  metadata {
    name = "account-service-db-secret"
  }
  data = {
    "db-password" = var.account_db_password
  }
}

resource "kubernetes_persistent_volume" "account_service_db_pv" {
  metadata {
    name = "account-service-pv"
  }
  spec {
    capacity = {
      storage = var.account_db_storage_size
    }
    volume_mode = "Filesystem"
    access_modes       = ["ReadWriteOncePod"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = kubernetes_storage_class.local_storage.metadata[0].name
    persistent_volume_source {
      host_path {
        path = "/mnt/disks/vol1"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_service" "account_service_db_svc" {
  metadata {
    name = "account-service-db-svc"
    labels = {
      app = "account-service"
    }
  }

  spec {
    port {
      port = 5432
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
            container_port = 5432
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
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "account-service-db-data"
      }
      spec {
        access_modes = ["ReadWriteOncePod"]
        storage_class_name = "local-storage"
        resources {
          requests = {
            storage = var.account_db_storage_size
          }
        }
      }
    }
  }
}