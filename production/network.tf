resource "terraform_data" "virtual_network" {
  input = {
    id     = "vnet-prod-001"
    cidr   = "10.20.0.0/16"
    region = "synthetic-region-1"
    owner  = "network-platform"
  }
}

resource "terraform_data" "public_subnet" {
  input = {
    id         = "subnet-public-prod-001"
    cidr       = "10.20.10.0/24"
    network_id = terraform_data.virtual_network.input.id
    route_type = "public"
  }

  depends_on = [terraform_data.virtual_network]
}

resource "terraform_data" "private_subnet" {
  input = {
    id         = "subnet-private-prod-001"
    cidr       = "10.20.20.0/24"
    network_id = terraform_data.virtual_network.input.id
    route_type = "private"
  }

  depends_on = [terraform_data.virtual_network]
}

resource "terraform_data" "network_security" {
  input = {
    id                = "nsg-platform-prod-001"
    network_id        = terraform_data.virtual_network.input.id
    public_subnet_id  = terraform_data.public_subnet.input.id
    private_subnet_id = terraform_data.private_subnet.input.id
    ingress           = ["443/tcp", "80/tcp"]
    egress            = ["all"]
    dns_suffix        = var.network_dns_suffix
  }

  depends_on = [
    terraform_data.virtual_network,
    terraform_data.public_subnet,
    terraform_data.private_subnet,
  ]
}