module "network" {
  source = "https://github.com/vk-cs/terraform-vkcs-network/archive/refs/tags/v0.0.2.zip//terraform-vkcs-network-0.0.2"

  name = "simple-tf-example"
  # Specify network name instead if default sdn contains more than one external network
  external_network = true

  networks = [{
    subnets = [{
      cidr = "192.168.199.0/24"
    }]
  }]
}
