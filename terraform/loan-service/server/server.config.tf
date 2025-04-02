resource "kubernetes_config_map" "loan_service_server_config" {
  metadata {
    name = "loan-service-server-config"
  }
  data = {
    DB_HOST = var.db_host
    HTTP_PORT = var.service_http_port
  }
}