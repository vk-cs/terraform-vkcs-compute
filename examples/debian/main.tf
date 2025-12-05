module "compute" {
  source = "../../"

  instances_count = 3

  # You can specify the `availability_zones` to distribute instances between them.
  # If you want all resources to be created in a single AZ, specify a list with one element.
  availability_zones = ["GZ1", "MS1", "ME1"]

  server_group = {
    name   = "server-group-tf-example"
    policy = ["anti-affinity"]
  }

  # You can turn off the plan using `enable_backup_plan`.
  # enable_backup_plan = false

  # You don't have to set the backup_plan settings,
  # then the default plan will be created.
  backup_plan = {
    name = "backup-tf-example"
    full_retention = {
      max_full_backup = 25
    }
    schedule = {
      date = ["Mo"]
      time = "04:00+03"
    }
  }

  name        = "compute-tf-example"
  flavor_name = "Basic-1-2-20"

  boot_volume = {
    tags        = ["boot"]
    name        = "boot-disk"
    description = "Boot disk for VM"
    image_id    = data.vkcs_images_image.debian.id
    type        = "ceph-ssd"
    size        = 10
  }

  data_volumes = [
    {
      tags        = ["data"]
      name        = "data-disk"
      description = "Extra data disk"
      type        = "ceph-ssd"
      size        = 20
    }
  ]

  # need for creating fips
  ext_net_name = "internet"
  ports = [
    {
      name               = "port-tf-example"
      network_id         = vkcs_networking_network.app.id
      security_group_ids = [vkcs_networking_secgroup.admin.id]
      tags               = ["port", "tf-example"]
    }
  ]

  depends_on = [vkcs_networking_router_interface.app]
}
