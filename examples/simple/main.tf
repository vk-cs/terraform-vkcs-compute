module "simple_compute" {
  source = "vk-cs/compute/vkcs"
  version = "0.0.1"

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
