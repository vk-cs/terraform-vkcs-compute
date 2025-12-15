module "network" {
  source = "../../../terraform-vkcs-network"

  name = "simple-tf-example"
  # Specify network name instead if default sdn contains more than one external network
  external_network = true

  networks = [{
    subnets = [{
      cidr = "192.168.199.0/24"
    }]
  }]
}
