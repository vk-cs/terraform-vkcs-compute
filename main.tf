resource "vkcs_compute_servergroup" "servergroup" {
  name = try(var.server_group.name, null) != null ? (
    var.server_group.name
    ) : (
    var.name
  )

  policies = var.server_group.policy
}

resource "vkcs_networking_port" "instance_ports" {
  count = var.instances_count * length(var.ports)

  name = try(var.ports[count.index % length(var.ports)].name, null) != null ? (
    "${var.ports[count.index % length(var.ports)].name}-${floor(count.index / length(var.ports))}-${count.index % length(var.ports)}"
    ) : (
    "${var.name}-${floor(count.index / length(var.ports))}-${count.index % length(var.ports)}"
  )

  region                       = var.region
  sdn                          = var.sdn
  network_id                   = var.ports[count.index % length(var.ports)].network_id
  description                  = var.ports[count.index % length(var.ports)].description
  dns_name                     = var.ports[count.index % length(var.ports)].dns_name
  full_security_groups_control = var.ports[count.index % length(var.ports)].full_security_groups_control
  security_group_ids           = var.ports[count.index % length(var.ports)].security_group_ids
  mac_address                  = var.ports[count.index % length(var.ports)].mac_address
  no_fixed_ip                  = var.ports[count.index % length(var.ports)].no_fixed_ip
  tags                         = setunion(var.tags, coalesce(var.ports[count.index % length(var.ports)].tags, []))

  dynamic "fixed_ip" {
    for_each = var.ports[count.index % length(var.ports)].fixed_ips != null ? var.ports[count.index % length(var.ports)].fixed_ips : []

    content {
      subnet_id  = fixed_ip.value.subnet_id
      ip_address = fixed_ip.value.ip_address
    }
  }

  dynamic "allowed_address_pairs" {
    for_each = var.ports[count.index % length(var.ports)].allowed_address_pairs != null ? var.ports[count.index % length(var.ports)].allowed_address_pairs : []

    content {
      ip_address  = allowed_address_pairs.value.ip_address
      mac_address = allowed_address_pairs.value.mac_address
    }
  }
}

resource "vkcs_networking_floatingip" "instance_fips" {
  count = var.ext_net_name != null ? var.instances_count * length(var.ports) : 0

  sdn     = var.sdn
  pool    = var.ext_net_name
  port_id = vkcs_networking_port.instance_ports[count.index].id
}

resource "vkcs_blockstorage_volume" "boot" {
  count = var.instances_count

  name = try(var.boot_volume.name, null) != null ? (
    "${var.boot_volume.name}-${count.index}"
    ) : (
    "${var.name}-${count.index}"
  )

  description       = var.boot_volume.description
  size              = var.boot_volume.size
  volume_type       = var.boot_volume.type
  availability_zone = local.instance_availability_zones[count.index]
  image_id          = var.boot_volume.image_id
}

resource "vkcs_blockstorage_volume" "data" {
  count = length(var.data_volumes) * var.instances_count

  name = try(var.data_volumes[count.index % length(var.data_volumes)].name, null) != null ? (
    "${var.data_volumes[count.index % length(var.data_volumes)].name}-${floor(count.index / length(var.data_volumes))}-${count.index % length(var.data_volumes)}"
    ) : (
    "${var.name}-${floor(count.index / length(var.data_volumes))}-${count.index % length(var.data_volumes)}"
  )

  description       = var.data_volumes[count.index % length(var.data_volumes)].description
  size              = var.data_volumes[count.index % length(var.data_volumes)].size
  volume_type       = var.data_volumes[count.index % length(var.data_volumes)].type
  availability_zone = local.instance_availability_zones[floor(count.index / length(var.data_volumes))]
}

resource "vkcs_compute_instance" "instances" {
  count = var.instances_count

  region            = var.region
  tags              = var.tags
  name              = "${var.name}-${count.index}"
  availability_zone = local.instance_availability_zones[count.index]
  flavor_name       = var.flavor_name
  flavor_id         = var.flavor_id
  key_pair          = var.key_pair
  admin_pass        = var.admin_pass
  config_drive      = var.config_drive
  user_data         = var.user_data

  scheduler_hints {
    group = vkcs_compute_servergroup.servergroup.id
  }

  dynamic "cloud_monitoring" {
    for_each = var.cloud_monitoring != null ? [1] : []
    content {
      script          = var.cloud_monitoring.script
      service_user_id = var.cloud_monitoring.service_user_id
    }
  }

  vendor_options {
    detach_ports_before_destroy = var.vendor_options.detach_ports_before_destroy
    get_password_data           = var.vendor_options.get_password_data
    ignore_resize_confirmation  = var.vendor_options.ignore_resize_confirmation
  }

  block_device {
    source_type           = "volume"
    boot_index            = 0
    uuid                  = vkcs_blockstorage_volume.boot[count.index].id
    destination_type      = "volume"
    delete_on_termination = false
  }

  dynamic "block_device" {
    for_each = { for idx, vol in vkcs_blockstorage_volume.data : idx => vol if floor(idx / length(var.data_volumes)) == count.index }

    content {
      source_type           = "volume"
      boot_index            = -1
      uuid                  = block_device.value.id
      destination_type      = "volume"
      delete_on_termination = false
    }
  }

  dynamic "network" {
    for_each = { for idx, port in vkcs_networking_port.instance_ports : idx => port if floor(idx / length(var.ports)) == count.index }

    content {
      port = network.value.id
    }
  }

  dynamic "personality" {
    for_each = var.personality != null ? var.personality : []
    content {
      file    = personality.value.file
      content = personality.value.content
    }
  }
}

resource "vkcs_backup_plan" "backup_plan" {
  count = var.enable_backup_plan ? 1 : 0

  name = (
    try(var.backup_plan.name, null) != null ? var.backup_plan.name : var.name
  )

  provider_name      = "cloud_servers"
  incremental_backup = var.backup_plan.incremental_backup
  region             = var.region
  instance_ids       = sort([for instance in vkcs_compute_instance.instances : instance.id])
  schedule           = try(var.backup_plan.schedule, null)
  full_retention     = try(var.backup_plan.full_retention, null)
  gfs_retention      = try(var.backup_plan.gfs_retention, null)
}
