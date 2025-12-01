module "compute" {
  source = "../"

  instances_count = 3

  # You can specify the `availability_zones` to distribute instances between them.
  # If you want all resources to be created in a single AZ, specify a list with one element.
  availability_zones = ["GZ1", "MS1", "ME1"]

  server_group = {
    name     = "server-group-tf-example"
    policies = ["anti-affinity"]
  }

  backup = {
    name            = "backup-tf-example"
    max_full_backup = 25
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

  networks = [
    {
      uuid = vkcs_networking_network.app.id
    }
  ]
}