module "shared" {
  source = "./shared"

  vpc_azs = var.vpc_azs

  depends_on = [module.eks]
}

module "account-service" {
  source = "./account-service"

  storage_class = module.shared.storage_class

  db_host = var.account_db_host
  db_user = var.account_db_user
  db_password = var.account_db_password
  db_name = var.account_db_name
  db_port = var.account_db_port
  db_storage_size = var.account_db_storage_size

  service_http_port = var.account_service_http_port
  service_replicas = var.account_service_replicas
  service_max_replicas = var.account_service_max_replicas
  service_min_replicas = var.account_service_min_replicas
  service_target_cpu_utilization_percentage = var.account_service_target_cpu_utilization_percentage
  service_server_image = var.account_service_server_image
  
  loan_service_address = var.account_service_loan_service_address
  
  depends_on = [module.eks, module.shared]
}

module "loan-service" {
  source = "./loan-service"

  storage_class = module.shared.storage_class

  db_host = var.loan_db_host
  db_user = var.loan_db_user
  db_password = var.loan_db_password
  db_name = var.loan_db_name
  db_port = var.loan_db_port
  db_storage_size = var.loan_db_storage_size

  service_http_port = var.loan_service_http_port
  service_replicas = var.loan_service_replicas
  service_max_replicas = var.loan_service_max_replicas
  service_min_replicas = var.loan_service_min_replicas
  service_target_cpu_utilization_percentage = var.loan_service_target_cpu_utilization_percentage
  service_server_image = var.loan_service_server_image
  
  depends_on = [module.eks, module.shared]
}
