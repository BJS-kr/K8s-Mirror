variable "loan_db_user" {
  description = "Database user for loan service"
  type        = string
}

variable "loan_db_password" {
  description = "Database password for loan service"
  type        = string
  sensitive   = true
}

variable "loan_db_host" {
  description = "Database host for loan service"
  type        = string
  sensitive = true
}

variable "loan_db_name" {
  description = "Database name for loan service"
  type        = string
  sensitive = true
}

variable "loan_db_port" {
  description = "Database port for loan service"
  type        = string
  sensitive = true
}

variable "loan_service_max_replicas" {
  description = "Maximum number of replicas for loan service"
  type        = number
}

variable "loan_service_min_replicas" {
  description = "Minimum number of replicas for loan service"
  type        = number
}


variable "loan_service_target_cpu_utilization_percentage" {
  description = "Target CPU utilization percentage for loan service"
  type        = number
}

variable "loan_service_http_port" {
  description = "HTTP port for loan service"
  type        = string
}

variable "loan_db_storage_size" {
  description = "Storage size for loan service database"
  type        = string
}

variable "loan_service_replicas" {
  description = "Number of replicas for loan service"
  type        = number
}

variable "loan_service_server_image" {
  description = "Image for loan service server"
  type        = string
}
