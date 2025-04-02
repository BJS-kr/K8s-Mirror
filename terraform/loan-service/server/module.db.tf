module "db" {
  source = "../db"

  db_password = var.db_password
  db_port = var.db_port
  db_storage_size = var.db_storage_size
  storage_class = var.storage_class
}