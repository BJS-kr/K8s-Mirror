resource "kubernetes_config_map" "account_service_server_config" {
  metadata {
    name = "account-service-server-config"
  }
  data = {
    DB_HOST = var.db_host
    HTTP_PORT = var.service_http_port
    LOAN_SERVICE_ADDR = var.loan_service_address
  }
}