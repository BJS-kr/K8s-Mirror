aws_region = "ap-northeast-2"

cluster_name    = "msa-cluster"
cluster_version = "1.32"
environment     = "test"

vpc_cidr             = "10.0.0.0/16"
vpc_name             = "msa-example-vpc"
vpc_azs              = ["ap-northeast-2a", "ap-northeast-2b"]
vpc_private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = true
enable_dns_hostnames = true

node_group_instance_types = ["t3.medium"]
node_group_min_size       = 2
node_group_max_size       = 2
node_group_desired_size   = 2
node_group_capacity_type  = "ON_DEMAND"

account_db_storage_size = "1Gi"
loan_db_storage_size    = "1Gi"

account_service_replicas = 2
loan_service_replicas    = 2

account_db_user     = "postgres"
account_db_password = "test"
account_db_host     = "account-service-db-svc"
account_db_name     = "postgres"
account_db_port     = "5432"
account_service_http_port = "8080"
account_service_server_image = "iron2ron/account-service:latest"

account_service_max_replicas = 10
account_service_min_replicas = 2
account_service_target_cpu_utilization_percentage = 50
account_service_loan_service_address = "http://loan-service-svc:8081"

loan_db_user        = "root"
loan_db_password    = "test"
loan_db_name        = "loan"
loan_db_port        = "3306"
loan_db_host        = "loan-service-db-svc"
loan_service_http_port = "8081"
loan_service_server_image = "iron2ron/loan-service:latest"

loan_service_max_replicas = 10
loan_service_min_replicas = 2
loan_service_target_cpu_utilization_percentage = 50