resource "terraform_data" "database" {
  input = {
    id            = "db-orders-prod-001"
    engine        = "synthetic-postgres"
    version       = "16"
    capacity_gb   = var.database_capacity_gb
    endpoint      = "db-orders.prod.internal:5432"
    subnet_id     = terraform_data.private_subnet.input.id
    security_zone = terraform_data.network_security.input.id
  }

  depends_on = [
    terraform_data.private_subnet,
    terraform_data.network_security,
  ]
}

resource "terraform_data" "database_backup" {
  input = {
    id                 = "db-backup-orders-prod-001"
    database_id        = terraform_data.database.input.id
    retention_days     = 35
    schedule           = "0 2 * * *"
    encryption_enabled = true
  }

  depends_on = [terraform_data.database]
}