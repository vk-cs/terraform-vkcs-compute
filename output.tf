output "instances" {
  value = [
    for idx, instance in vkcs_compute_instance.instances : {
      id                = instance.id
      availability_zone = instance.availability_zone
      ports = [
        for port in local.all_ports : {
          id          = vkcs_networking_port.ports[port.port_key].id
          name        = vkcs_networking_port.ports[port.port_key].name
          fixed_ip    = vkcs_networking_port.ports[port.port_key].all_fixed_ips[0]
          mac_address = vkcs_networking_port.ports[port.port_key].mac_address
          dns_name    = vkcs_networking_port.ports[port.port_key].dns_name
          floating_ip = (
            port.floatingip_pool != null && port.floatingip_pool != false ?
            vkcs_networking_floatingip.floatingips[port.port_key].address :
            null
          )
        } if port.instance_idx == idx
      ]
      volumes = [
        for volume in local.all_volumes : {
          id   = vkcs_blockstorage_volume.volumes[volume.volume_key].id
          name = vkcs_blockstorage_volume.volumes[volume.volume_key].name
        } if volume.instance_idx == idx
      ]
      password_data = instance.password_data
    }
  ]
  description = "List of the instances info."
}

output "servergroup_id" {
  value       = try(vkcs_compute_servergroup.servergroup[0].id, null)
  description = "Server group ID."
}

output "backup_plan_id" {
  value       = var.backup_plan != null ? vkcs_backup_plan.backup_plan[0].id : null
  description = "Backup plan ID."
}
