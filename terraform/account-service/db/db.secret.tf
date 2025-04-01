resource "kubernetes_secret" "account_service_db_secret" {
  metadata {
    name = "account-service-db-secret"
  }
  data = {
    "db-password" = var.db_password
  }
}