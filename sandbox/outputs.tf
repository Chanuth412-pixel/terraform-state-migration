output "resource_inventory" {
  description = "Synthetic infrastructure identity and ownership inventory."
  value = {
    virtual_network    = terraform_data.virtual_network.input
    public_subnet      = terraform_data.public_subnet.input
    private_subnet     = terraform_data.private_subnet.input
    network_security   = terraform_data.network_security.input
    application_server = terraform_data.application_server.input
    load_balancer      = terraform_data.load_balancer.input
    database           = terraform_data.database.input
    database_backup    = terraform_data.database_backup.input
  }
}