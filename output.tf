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
      instance_id       = instance.id
      fixed_ip          = instance.network[0].fixed_ip_v4
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