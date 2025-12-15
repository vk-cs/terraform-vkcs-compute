data "vkcs_images_image" "base" {
  visibility = "public"
  default    = true
  properties = {
    mcs_os_distro  = "debian"
    mcs_os_version = "12"
  }
}

resource "vkcs_cloud_monitoring" "base" {
  image_id = data.vkcs_images_image.base.id
}

resource "vkcs_networking_port" "cluster_vip" {
  tags       = ["tf-example"]
  network_id = module.network.networks[1].id
  fixed_ip {
    subnet_id = module.network.networks[1].subnets[1].id
  }
  full_security_groups_control = true
}
