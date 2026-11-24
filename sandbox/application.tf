resource "terraform_data" "application_server" {
  input = {
    id                = "app-orders-prod-001"
    role              = "orders-api"
    subnet_id         = terraform_data.private_subnet.input.id
    database_id       = terraform_data.database.input.id
    database_endpoint = terraform_data.database.input.endpoint
    instance_shape    = "synthetic-2cpu-4gb"
  }

  depends_on = [
    terraform_data.private_subnet,
    terraform_data.database,
  ]
}

resource "terraform_data" "load_balancer" {
  input = {
    id               = "lb-orders-prod-001"
    public_subnet_id = terraform_data.public_subnet.input.id
    app_server_id    = terraform_data.application_server.input.id
    scheme           = "internet-facing"
  }

  depends_on = [
    terraform_data.public_subnet,
    terraform_data.application_server,
  ]
}