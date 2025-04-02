variable "db_password" {
  description = "Database password for account service"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port for account service"
  type        = string
  sensitive = true
}

variable "db_storage_size" {
  description = "Storage size for account service database"
  type        = string
}

variable "storage_class" {
  description = "Storage class for account service database"
  type        = any
}