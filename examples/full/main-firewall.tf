module "firewall_admin" {
  source = "vk-cs/firewall/vkcs"
  version = "~> 0.0.1"

  name        = "admin-tf-example"
  description = "Admin access. Full firewall TF module example."
  tags        = ["tf-example"]

  rules = [
    {
      description      = "SSH rule. Full firewall TF module example."
      protocol         = "tcp"
      port             = 22
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      description      = "Ping rule. Full firewall TF module example."
      protocol         = "icmp"
      remote_ip_prefix = "0.0.0.0/0"
    },
  ]
}

module "firewall_http" {
  source = "vk-cs/firewall/vkcs"
  version = "~> 0.0.1"

  name        = "http-tf-example"
  description = "HTTP access. Full firewall TF module example."
  tags        = ["tf-example"]

  rules = [
    {
      description      = "HTTPS rule. Full firewall TF module example."
      protocol         = "tcp"
      port             = 443
      remote_ip_prefix = "0.0.0.0/0"
    },
    {
      description = "HTTP rule. Full firewall TF module example."
      protocol    = "tcp"
      port        = 80
      # Allow access from application network only
      remote_ip_prefix = "192.168.199.0/24"
    },
    {
      description    = "Alternative HTTP rules. Full firewall TF module example."
      protocol       = "tcp"
      port_range_min = 8080
      port_range_max = 8089
      # Allow access from application network only
      remote_ip_prefix = "192.168.199.0/24"
    },
  ]
}

module "firewall_vrrp" {
  source = "vk-cs/firewall/vkcs"
  version = "~> 0.0.1"

  name                 = "vrrp-tf-example"
  description          = "VRRP internal firewall. Full firewall TF module example"
  tags                 = ["tf-example"]
  delete_default_rules = true

  # NOTE: This is just an example of module usage. Real VRRP activity was not tested with this.
  rules = [
    {
      direction       = "egress"
      protocol        = "vrrp"
      remote_group_id = module.firewall_vrrp.secgroup_id
    },
    {
      direction        = "egress"
      protocol         = "vrrp"
      remote_ip_prefix = "224.0.0.18/32"
    },
    {
      direction       = "ingress"
      protocol        = "vrrp"
      remote_group_id = module.firewall_vrrp.secgroup_id
    },
    {
      direction        = "egress"
      protocol         = "udp"
      port             = "53"
      remote_ip_prefix = "0.0.0.0/32"
    },
    {
      direction        = "ingress"
      protocol         = "udp"
      port             = "53"
      remote_ip_prefix = "0.0.0.0/32"
    },
  ]
}
