variable "account_db_user" {
  description = "Database user for account service"
  type        = string
}

variable "account_db_password" {
  description = "Database password for account service"
  type        = string
  sensitive   = true
}

variable "account_db_host" {
  description = "Database host for account service"
  type        = string
  sensitive = true
}

variable "account_db_name" {
  description = "Database name for account service"
  type        = string
  sensitive = true
}

variable "account_db_port" {
  description = "Database port for account service"
  type        = string
  sensitive = true
}


variable "account_service_max_replicas" {
  description = "Maximum number of replicas for account service"
  type        = number
}

variable "account_service_min_replicas" {
  description = "Minimum number of replicas for account service"
  type        = number
}


variable "account_service_target_cpu_utilization_percentage" {
  description = "Target CPU utilization percentage for account service"
  type        = number
}

variable "account_service_http_port" {
  description = "HTTP port for account service"
  type        = string
}

variable "account_db_storage_size" {
  description = "Storage size for account service database"
  type        = string
}


variable "account_service_replicas" {
  description = "Number of replicas for account service"
  type        = number
}

variable "account_service_loan_service_address" {
  description = "Address of the loan service"
  type        = string
}

variable "account_service_server_image" {
  description = "Image for account service server"
  type        = string
}