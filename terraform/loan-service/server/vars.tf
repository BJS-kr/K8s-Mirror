variable "db_port" {
  description = "Database port for loan service"
  type        = string
  sensitive = true
}

variable "db_host" {
  description = "Database host for loan service"
  type        = string
  sensitive = true
}

variable "db_storage_size" {
  description = "Storage size for loan service database"
  type        = string
}

variable "db_password" {
  description = "Database password for loan service"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Database user for loan service"
  type        = string
}

variable "db_name" {
  description = "Database name for loan service"
  type        = string
  sensitive = true
}

variable "service_http_port" {
  description = "HTTP port for loan service"
  type        = string
}

variable "service_replicas" {
  description = "Number of replicas for loan service"
  type        = number
}

variable "service_max_replicas" {
  description = "Maximum number of replicas for loan service"
  type        = number
}

variable "service_min_replicas" {
  description = "Minimum number of replicas for loan service"
  type        = number
}

variable "service_target_cpu_utilization_percentage" {
  description = "Target CPU utilization percentage for loan service"
  type        = number
}

variable "service_server_image" {
  description = "Image for loan service server"
  type        = string
}

variable "storage_class" {
  description = "Storage class for loan service database"
  type        = any
}