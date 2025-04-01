resource "kubernetes_secret" "account_service_server_secret" {
  metadata {
    name = "account-service-server-secret"
  }
  data = {
    DB_NAME = var.db_name
    DB_PASSWORD = var.db_password
    DB_PORT = var.db_port
    DB_USER = var.db_user
  }
}
