output "server_group_id" {
  value       = vkcs_compute_servergroup.servergroup.id
  description = "Id of the server group."
}

output "backup_plan_id" {
  value       = var.enable_backup_plan ? vkcs_backup_plan.backup_plan[0].id : null
  description = "Id of the backup plan."
}

output "instances" {
  value = [
    for idx, instance in vkcs_compute_instance.instances : {
      instance_id = instance.id
      fixed_ip    = instance.network[0].fixed_ip_v4
      network_info = [
        for port_idx in range(length(var.ports)) : {
          port_id = vkcs_networking_port.instance_ports[idx * length(var.ports) + port_idx].id
          floating_ip = var.ext_net_name != null ? try(
            vkcs_networking_floatingip.instance_fips[idx * length(var.ports) + port_idx].address,
            null
          ) : null
        }
      ]
      availability_zone = instance.availability_zone
      boot_volume_id    = try(vkcs_blockstorage_volume.boot[idx].id, null)
      data_volume_ids = [
        for vol_idx, vol in vkcs_blockstorage_volume.data :
        vol.id if floor(vol_idx / length(var.data_volumes)) == idx
      ]
      password_data = instance.password_data
    }
  ]
  description = "List of the instances info."
}