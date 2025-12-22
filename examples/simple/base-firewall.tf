module "firewall_all" {
  source = "https://github.com/vk-cs/terraform-vkcs-firewall/archive/refs/tags/v0.0.3.zip//terraform-vkcs-firewall-0.0.3"

  name = "all-tf-example"

  rules = [{
    remote_ip_prefix = "0.0.0.0/0"
  }]
}
