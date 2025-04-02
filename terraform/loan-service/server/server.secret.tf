resource "kubernetes_secret" "loan_service_server_secret" {
  metadata {
    name = "loan-service-server-secret"
  }
  data = {
    DB_NAME = var.db_name
    DB_PASSWORD = var.db_password
    DB_PORT = var.db_port
    DB_USER = var.db_user
  }
}
