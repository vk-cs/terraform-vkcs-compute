resource "vkcs_compute_servergroup" "servergroup" {
  count = var.cluster != null && var.cluster.servergroup_policy != null ? 1 : 0

  region   = var.region
  name     = coalesce(try(var.cluster.servergroup_name, ""), var.name)
  policies = [var.cluster.servergroup_policy]
}

resource "vkcs_blockstorage_volume" "volumes" {
  for_each = { for p in local.all_volumes : p.volume_key => p }

  region = var.region
  name = join("", [
    coalesce(each.value.name, var.name),
    "%{if var.cluster != null}-${each.value.instance_idx}%{else}%{endif}",
    "%{if !can(coalesce(each.value.name))}-${each.value.volume_idx}%{else}%{endif}"
  ])
  description       = each.value.description
  availability_zone = local.instance_availability_zones[each.value.instance_idx]
  volume_type       = each.value.type
  size              = each.value.size
  image_id          = each.value.image_id
}

resource "vkcs_networking_port" "ports" {
  for_each = { for p in local.all_ports : p.port_key => p }

  network_id                   = each.value.network_id
  full_security_groups_control = true
  region                       = var.region
  tags                         = setunion(var.tags, coalesce(each.value.tags, []))
  name = join("", [
    coalesce(each.value.name, var.name),
    "%{if var.cluster != null}-${each.value.instance_idx}%{else}%{endif}",
    "%{if !can(coalesce(each.value.name))}-${each.value.port_idx}%{else}%{endif}"
  ])
  description        = each.value.description
  security_group_ids = each.value.security_group_ids
  mac_address        = each.value.mac_address

  dynamic "fixed_ip" {
    for_each = (
      each.value.subnet_id != null ?
      [each.value] :
      []
    )
    content {
      subnet_id  = fixed_ip.value.subnet_id
      ip_address = fixed_ip.value.ip_address
    }
  }

  dynamic "allowed_address_pairs" {
    for_each = (
      each.value.allowed_address_pairs != null ?
      each.value.allowed_address_pairs :
      []
    )
    content {
      ip_address  = allowed_address_pairs.value.ip_address
      mac_address = allowed_address_pairs.value.mac_address
    }
  }
}

resource "vkcs_networking_floatingip" "floatingips" {
  for_each = {
    for p in local.all_ports : p.port_key => p
    if p.floatingip_pool != null && p.floatingip_pool != false
  }

  region = var.region
  pool = (
    (
      each.value.floatingip_pool == true &&
      # not required at all but this is workaround of TF bug:
      # if evaluation of data.vkcs_networking_network.pools is postponed to apply stage
      # TF evaluates pool argument to null and passes it to the resource which produces an error
      vkcs_networking_port.ports[each.key].id != null
    ) ?
    data.vkcs_networking_network.pools[each.value.port_idx].name :
    each.value.floatingip_pool
  )
  port_id = vkcs_networking_port.ports[each.key].id
  description = each.value.floatingip_description
}

resource "vkcs_compute_instance" "instances" {
  count = local.instance_count

  region            = var.region
  tags              = var.tags
  name              = var.cluster == null ? var.name : "${var.name}-${count.index}"
  availability_zone = local.instance_availability_zones[count.index]
  flavor_name       = var.flavor_name
  flavor_id         = var.flavor_id
  key_pair          = var.key_pair
  config_drive      = var.config_drive
  user_data         = var.user_data
  admin_pass        = var.admin_pass

  dynamic "scheduler_hints" {
    for_each = length(vkcs_compute_servergroup.servergroup) > 0 ? [1] : []

    content {
      group = vkcs_compute_servergroup.servergroup[0].id
    }
  }

  dynamic "block_device" {
    for_each = { for v in local.all_volumes : v.volume_key => v if v.instance_idx == count.index }

    content {
      source_type           = "volume"
      destination_type      = "volume"
      uuid                  = vkcs_blockstorage_volume.volumes[block_device.key].id
      boot_index            = block_device.value.volume_idx == 0 ? 0 : -1
      delete_on_termination = false
    }
  }

  dynamic "network" {
    for_each = { for p in local.all_ports : p.port_key => p if p.instance_idx == count.index }

    content {
      port = vkcs_networking_port.ports[network.key].id
    }
  }

  dynamic "cloud_monitoring" {
    for_each = var.cloud_monitoring != null ? [1] : []

    content {
      script          = var.cloud_monitoring.script
      service_user_id = var.cloud_monitoring.service_user_id
    }
  }

  dynamic "personality" {
    for_each = var.personality != null ? var.personality : []

    content {
      file    = personality.value.file
      content = personality.value.content
    }
  }

  dynamic "vendor_options" {
    for_each = var.vendor_options != null ? [1] : []

    content {
      detach_ports_before_destroy = var.vendor_options.detach_ports_before_destroy
      get_password_data           = var.vendor_options.get_password_data
      ignore_resize_confirmation  = var.vendor_options.ignore_resize_confirmation
    }
  }
}

resource "vkcs_backup_plan" "backup_plan" {
  count = var.backup_plan != null ? 1 : 0

  region             = var.region
  name               = coalesce(var.backup_plan.name, var.name)
  provider_name      = "cloud_servers"
  instance_ids       = vkcs_compute_instance.instances[*].id
  incremental_backup = var.backup_plan.incremental_backup
  schedule           = var.backup_plan.schedule
  full_retention     = var.backup_plan.full_retention
  gfs_retention      = var.backup_plan.gfs_retention
}
