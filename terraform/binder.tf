module "account-service" {
  source = "./account-service"

  db_host = var.account_db_host
  db_user = var.account_db_user
  db_password = var.account_db_password
  db_name = var.account_db_name
  db_port = var.account_db_port
  service_http_port = var.account_service_http_port
  service_replicas = var.account_service_replicas
  service_max_replicas = var.account_service_max_replicas
  service_min_replicas = var.account_service_min_replicas
  service_target_cpu_utilization_percentage = var.account_service_target_cpu_utilization_percentage
  loan_service_address = var.account_service_loan_service_address
  db_storage_size = var.account_db_storage_size
  
  depends_on = [module.eks]
}

module "loan-service" {
  source = "./loan-service"
  depends_on = [module.eks]
}
