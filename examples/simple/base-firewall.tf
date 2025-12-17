module "firewall_all" {
  source = "vk-cs/firewall/vkcs"
  version = "~> 0.0.1"

  name = "all-tf-example"

  rules = [{
    remote_ip_prefix = "0.0.0.0/0"
  }]
}
