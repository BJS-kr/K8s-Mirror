module "service" {
  source = "./server"

  storage_class = var.storage_class
  
  db_host = var.db_host
  db_password = var.db_password
  db_name = var.db_name
  db_port = var.db_port
  db_user = var.db_user
  db_storage_size = var.db_storage_size

  service_http_port = var.service_http_port
  service_replicas = var.service_replicas
  service_max_replicas = var.service_max_replicas
  service_min_replicas = var.service_min_replicas
  service_target_cpu_utilization_percentage = var.service_target_cpu_utilization_percentage
  service_server_image = var.service_server_image

  loan_service_address = var.loan_service_address
}
