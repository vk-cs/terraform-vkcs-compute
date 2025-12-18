module "simple_compute" {
  source = "https://github.com/vk-cs/terraform-vkcs-compute/archive/refs/tags/v0.0.2.zip//terraform-vkcs-compute-0.0.2"
  # Alternatively you may refer right to Hashicorp module repository if you have access to it
  # source = "vk-cs/compute/vkcs"
  # version = "0.0.2"

  name              = "simple-compute-tf-example"
  availability_zone = "GZ1"
  flavor_name       = "STD3-1-2"
  volumes = [{
    image_id = data.vkcs_images_image.debian.id
    type     = "ceph-ssd"
    size     = 10
  }]
  ports = [{
    network_id         = module.network.networks[0].id
    security_group_ids = [module.firewall_all.secgroup_id]
    floatingip_pool    = true
  }]
}
