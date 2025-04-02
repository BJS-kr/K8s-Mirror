variable "db_password" {
  description = "Database password for loan service"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database port for loan service"
  type        = string
  sensitive = true
}

variable "db_storage_size" {
  description = "Storage size for loan service database"
  type        = string
}

variable "storage_class" {
  description = "Storage class for loan service database"
  type        = any
}