resource "kubernetes_secret" "loan_service_db_secret" {
  metadata {
    name = "loan-service-db-secret"
  }
  data = {
    "db-password" = var.db_password
  }
}