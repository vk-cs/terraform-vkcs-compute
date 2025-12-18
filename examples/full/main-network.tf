module "network" {
  source = "https://github.com/vk-cs/terraform-vkcs-network/archive/refs/tags/v0.0.2.zip//terraform-vkcs-network-0.0.2"

  tags = ["tf-example"]
  name = "full-tf-example"
  description = "Full network TF module example."
  # Specify network name instead if default sdn contains more than one external network
  external_network = true

  networks = [
    {
      # Add additional tags to tags inherited from the module
      tags        = ["public"]
      # Overwrite name, otherwise it is inherited from the module
      name        = "public-tf-example"
      description = "Public access. Full network TF module example."
      subnets = [
        {
          # Add additional tags to tags inherited from the module. Network tags are not inherited
          tags = ["public"]
          # Overwrite name too, since it is not inherited from the network
          name = "public-tf-example"
          description = "Full network TF module example."
          cidr = "192.168.199.0/24"
        }
      ]
    },
    {
      name        = "internal-tf-example"
      description = "Internal communication. Full network TF module example."
      tags        = ["internal"]
      subnets = [
        {
          tags = ["internal"]
          name = "internal-tf-example"
          description = "Full network TF module example."
          cidr = "192.168.166.0/24"
          allocation_pool = [
            {
              start = "192.168.166.3"
              end = "192.168.166.254"
            }
          ]
          gateway_ip = "192.168.166.1"
          routes = [
            {
              destination_cidr = "0.0.0.0/0"
              next_hop = "192.168.166.2"
            }
          ]
        },
        {
          # name and tags are inherited from the module
          cidr = "192.168.167.0/24"
          enable_dhcp = false
          enable_private_dns = false  # Does nothing for neutron sdn
        },
      ]
    }
  ]
}
