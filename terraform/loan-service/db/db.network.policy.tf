resource "kubernetes_network_policy" "loan_service_db_network_policy" {
  metadata {
    name = "loan-service-db-network-policy"
  }
  spec {
    pod_selector {
      match_labels = {
        app = "loan-service"
        role = "db"
      }
    }
    policy_types = ["Ingress", "Egress"]
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "loan-service"
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
            app = "loan-service"
            role = "server"
          }
        }
      }
    }
  }
}