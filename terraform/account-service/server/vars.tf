variable "db_port" {
  description = "Database port for account service"
  type        = string
  sensitive = true
}

variable "db_host" {
  description = "Database host for account service"
  type        = string
  sensitive = true
}

variable "db_password" {
  description = "Database password for account service"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Database user for account service"
  type        = string
}

variable "db_storage_size" {
  description = "Storage size for account service database"
  type        = string
}


variable "db_name" {
  description = "Database name for account service"
  type        = string
  sensitive = true
}

variable "service_http_port" {
  description = "HTTP port for account service"
  type        = string
}

variable "service_replicas" {
  description = "Number of replicas for account service"
  type        = number
}

variable "service_max_replicas" {
  description = "Maximum number of replicas for account service"
  type        = number
}

variable "service_min_replicas" {
  description = "Minimum number of replicas for account service"
  type        = number
}


variable "service_target_cpu_utilization_percentage" {
  description = "Target CPU utilization percentage for account service"
  type        = number
}

variable "loan_service_address" {
  description = "Address of the loan service"
  type        = string
}

variable "service_server_image" {
  description = "Image for account service server"
  type        = string
}

variable "storage_class" {
  description = "Storage class for account service database"
  type        = any
}