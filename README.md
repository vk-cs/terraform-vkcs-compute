<!-- BEGIN_TF_DOCS -->
![Beta Status](https://img.shields.io/badge/Status-Beta-yellow)

# VKCS Compute Terraform module
A Terraform module for creating `Compute` in VKCS.

## Examples
You can find examples in the [`examples`](./examples) directory.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_vkcs"></a> [vkcs](#requirement\_vkcs) | < 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [vkcs_backup_plan.backup_plan](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/backup_plan) | resource |
| [vkcs_blockstorage_volume.boot](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/blockstorage_volume) | resource |
| [vkcs_blockstorage_volume.data](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/blockstorage_volume) | resource |
| [vkcs_compute_instance.instances](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/compute_instance) | resource |
| [vkcs_compute_servergroup.servergroup](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/compute_servergroup) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_pass"></a> [admin\_pass](#input\_admin\_pass) | The administrative password to assign to the server. | `string` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for spreading instances. | `list(string)` | n/a | yes |
| <a name="input_backup_plan"></a> [backup\_plan](#input\_backup\_plan) | Configuration for backup plan.<br/>When `enable_backup_plan = true`:<br/>- If this variable is set: Uses provided configuration<br/>- If this variable is null: Uses default backup plan configuration<br/>When `enable_backup_plan = false`: This variable is ignored<br/>See `vkcs_backup_plan` arguments. | <pre>object({<br/>    name               = string<br/>    incremental_backup = optional(bool, false)<br/>    schedule = object({<br/>      date        = optional(list(string))<br/>      every_hours = optional(number)<br/>      time        = optional(string)<br/>    })<br/>    full_retention = optional(object({<br/>      max_full_backup = number<br/>    }))<br/>    gfs_retention = optional(object({<br/>      gfs_weekly  = number<br/>      gfs_monthly = optional(number)<br/>      gfs_yearly  = optional(number)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "full_retention": {<br/>    "max_full_backup": 25<br/>  },<br/>  "name": "default-backup-plan",<br/>  "schedule": {<br/>    "date": [<br/>      "Mo"<br/>    ],<br/>    "time": "04:00+03"<br/>  }<br/>}</pre> | no |
| <a name="input_boot_volume"></a> [boot\_volume](#input\_boot\_volume) | Configuration for the boot volume. | <pre>object({<br/>    tags        = list(string)<br/>    name        = string<br/>    description = string<br/>    type        = string<br/>    size        = number<br/>    image_id    = string<br/>  })</pre> | n/a | yes |
| <a name="input_cloud_monitoring"></a> [cloud\_monitoring](#input\_cloud\_monitoring) | The settings of the cloud monitoring. | <pre>object({<br/>    script          = string<br/>    service_user_id = string<br/>  })</pre> | `null` | no |
| <a name="input_config_drive"></a> [config\_drive](#input\_config\_drive) | Whether to use the config\_drive feature to configure the instance. | `bool` | `null` | no |
| <a name="input_data_volumes"></a> [data\_volumes](#input\_data\_volumes) | List of data volume configurations. | <pre>list(object({<br/>    tags        = list(string)<br/>    name        = string<br/>    description = string<br/>    type        = string<br/>    size        = number<br/>  }))</pre> | `null` | no |
| <a name="input_enable_backup_plan"></a> [enable\_backup\_plan](#input\_enable\_backup\_plan) | Enables or disables creation of backup plan.<br/>If `true`: Creates backup plan using custom or default settings.<br/>If `false`: No backup plan is created. | `bool` | `true` | no |
| <a name="input_flavor_id"></a> [flavor\_id](#input\_flavor\_id) | The flavor ID of the desired flavor for the server. Required if flavor\_name is empty. | `string` | `null` | no |
| <a name="input_flavor_name"></a> [flavor\_name](#input\_flavor\_name) | The name of the desired flavor for the server. Required if flavor\_id is empty. | `string` | `null` | no |
| <a name="input_instances_count"></a> [instances\_count](#input\_instances\_count) | Number of VM instances to create | `number` | n/a | yes |
| <a name="input_key_pair"></a> [key\_pair](#input\_key\_pair) | The name of a key pair to put on the server. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the compute resources. | `string` | n/a | yes |
| <a name="input_networks"></a> [networks](#input\_networks) | An array of one or more networks to attach to the instance. | <pre>list(object({<br/>    access_network = optional(bool)<br/>    fixed_ip_v4    = optional(string)<br/>    name           = optional(string)<br/>    port           = optional(string)<br/>    uuid           = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_personality"></a> [personality](#input\_personality) | Customize the personality of an instance by defining one or more files and their contents. | <pre>list(object({<br/>    content = string<br/>    file    = string<br/>  }))</pre> | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which to create the server instance. | `string` | `null` | no |
| <a name="input_server_group"></a> [server\_group](#input\_server\_group) | Configuration for creating a server group.<br/>`policy` needs for `vkcs_compute_servergroup.policies`<br/>See `vkcs_compute_servergroup` arguments. | <pre>object({<br/>    name   = string<br/>    policy = optional(set(string))<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A set of string tags for the instance. | `set(string)` | `[]` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The user data to provide when launching the instance. | `string` | `null` | no |
| <a name="input_vendor_options"></a> [vendor\_options](#input\_vendor\_options) | Map of additional vendor-specific options. | <pre>object({<br/>    detach_ports_before_destroy = optional(bool)<br/>    get_password_data           = optional(bool)<br/>    ignore_resize_confirmation  = optional(bool)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_id"></a> [backup\_plan\_id](#output\_backup\_plan\_id) | Id of the backup plan. |
| <a name="output_instances"></a> [instances](#output\_instances) | List of the instances info. |
| <a name="output_server_group_id"></a> [server\_group\_id](#output\_server\_group\_id) | Id of the server group. |
<!-- END_TF_DOCS -->