module "network" {
  source = "vk-cs/network/vkcs"
  version = "~> 0.0.1"

  name = "simple-tf-example"
  # Specify network name instead if default sdn contains more than one external network
  external_network = true

  networks = [{
    subnets = [{
      cidr = "192.168.199.0/24"
    }]
  }]
}
