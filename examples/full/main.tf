module "full_compute" {
  source = "vk-cs/compute/vkcs"

  tags = ["tf-example"]
  name = "full-compute-tf-example"
  cluster = {
    size               = 3
    servergroup_name   = "cluster-tf-example"
    servergroup_policy = "anti-affinity"
    availability_zones = ["GZ1", "MS1"]  # Count of zones can be less than cluster size
  }
  flavor_name = "STD3-1-2"
  volumes = [
    {
      # Overwrite name, otherwise it is inherited from the module
      name        = "boot-disk"
      description = "Boot disk. Full compute TF module example."
      type        = "ceph-ssd"
      size        = 10
      image_id    = data.vkcs_images_image.base.id
    },
    {
      name        = "data-disk"
      description = "Extra data disk. Full compute TF module example"
      type        = "ceph-ssd"
      size        = 20
    },
  ]
  ports = [
    {
      # Add additional tags to tags inherited from the module
      tags = ["public"]
      # Overwrite name, otherwise it is inherited from the module
      name        = "public"
      description = "Public cluster access. Full compute TF module example."
      network_id  = module.network.networks[0].id
      security_group_ids = [
        module.firewall_admin.secgroup_id,
        module.firewall_http.secgroup_id,
      ]
      floatingip_pool        = true
      floatingip_description = "External cluster access. Full compute TF module example."
    },
    {
      tags        = ["internal"]
      name        = "internal"
      description = "Internal cluster access. Full compute TF module example."
      network_id  = module.network.networks[1].id
      subnet_id   = module.network.networks[1].subnets[0].id
      security_group_ids = [
        module.firewall_http.secgroup_id,
      ]
    },
    {
      # name and tags are inherited from the module
      network_id = module.network.networks[1].id
      subnet_id  = module.network.networks[1].subnets[1].id
      security_group_ids = [
        module.firewall_vrrp.secgroup_id,
      ]
      allowed_address_pairs = [{
        ip_address = vkcs_networking_port.cluster_vip.all_fixed_ips[0]
      }]
    },
  ]
  cloud_monitoring = {
    service_user_id = vkcs_cloud_monitoring.base.service_user_id
    script          = vkcs_cloud_monitoring.base.script
  }
  config_drive = true
  personality = [{
    file    = "/opt/app/config.json"
    content = jsonencode({ "foo" : "bar" })
  }]
  user_data      = <<EOF
    #cloud-config
    package_upgrade: true
    packages:
      - nginx
    runcmd:
      - systemctl start nginx
  EOF
  vendor_options = null
  # Overwrite default backup plan
  backup_plan = {
    # name is inherited from the module
    incremental_backup = false
    schedule = {
      date = ["Mo", "We", "Fr"]
      time = "01:00+03"
    }
    full_retention = {
      max_full_backup = 10
    }
  }
}
