<!-- BEGIN_TF_DOCS -->
![Beta Status](https://img.shields.io/badge/Status-Beta-yellow)

# VKCS Compute Terraform module
A Terraform module for `Compute` in VKCS.

This modules makes it easy to setup virtual machines in VKCS.

It supports creating:
- compute servergroup
- compute instances
- blockstorage volumes
- network ports
- network floatingips (associated with the ports)
- backup plan

It does not support:
- multiple IPs on one ports
- adding new ports
- adding new volumes

## Usage
### Enable all traffic
```hcl
module "simple_compute" {
  source = "vk-cs/compute/vkcs"

  name              = "simple-compute-tf-example"
  availability_zone = "GZ1"
  flavor_name       = "STD3-1-2"
  volumes = [{
    image_id = data.vkcs_images_image.debian.id
    type     = "ceph-ssd"
    size     = 10
  }]
  ports = [{
    network_id         = module.network.networks[0].id
    security_group_ids = [module.firewall_all.secgroup_id]
    floatingip_pool    = true
  }]
}
```

## Examples
You can find examples in the [`examples`](./examples) directory on [GitHub](https://github.com/vk-cs/terraform-vkcs-compute/tree/v0.0.1/examples).

Running an example:
- Clone [GitHub repository](https://github.com/vk-cs/terraform-vkcs-compute) and checkout tag v0.0.1.
- [Install Terraform](https://cloud.vk.com/docs/en/tools-for-using-services/terraform/quick-start). **Note**: You do not need `vkcs_provider.tf` to run module example.
- [Init Terraform](https://cloud.vk.com/docs/en/tools-for-using-services/terraform/quick-start#terraform_initialization) from the example folder.
- [Run Terraform](https://cloud.vk.com/docs/en/tools-for-using-services/terraform/quick-start#creating_resources_via_terraform) to create example resources.
- Check example output and explore created resources with `terraform show`, management console, CLI and API requests.
- Remove example resources with `terraform destroy -auto-approve --refresh=false`

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3)

- <a name="requirement_vkcs"></a> [vkcs](#requirement\_vkcs) (>= 0.13.1, < 1.0.0)

## Resources

The following resources are used by this module:

- [vkcs_backup_plan.backup_plan](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/backup_plan) (resource)
- [vkcs_blockstorage_volume.volumes](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/blockstorage_volume) (resource)
- [vkcs_compute_instance.instances](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/compute_instance) (resource)
- [vkcs_compute_servergroup.servergroup](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/compute_servergroup) (resource)
- [vkcs_networking_floatingip.floatingips](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/networking_floatingip) (resource)
- [vkcs_networking_port.ports](https://registry.terraform.io/providers/vk-cs/vkcs/latest/docs/resources/networking_port) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: Default name for module resources. Used when name is not specified for a resource.

Type: `string`

### <a name="input_volumes"></a> [volumes](#input\_volumes)

Description: Configuration for the boot volume.  
See `vkcs_blockstorage_volume` arguments for details. If name is not set it is assigned to `name` module variable.  
At least one volume must be specified. The first volume requires `image_id`.

Type:

```hcl
list(object({
    name        = optional(string)
    description = optional(string)
    type        = string
    size        = number
    image_id    = optional(string)
  }))
```

### <a name="input_ports"></a> [ports](#input\_ports)

Description: List of ports to create and attach to instances.

See `vkcs_networking_port` arguments for details. If name is not set it is assigned to `name` module variable.

`subnet_id` and `ip_address` - arguments for the first `fixed_ips` element in `vkcs_networking_port`. Next elements are not supported by the module.

`floatingip_pool` - allocate and associate floating IP to the port. Specify external network name or set `true` if the only external netwrok is available in the project.

`floatingip_description` - `description` argument for `vkcs_networking_floatingip` resource.

At least one port must be specified.

Type:

```hcl
list(object({
    network_id         = string
    tags               = optional(list(string))
    name               = optional(string)
    description        = optional(string)
    subnet_id          = optional(string)
    ip_address         = optional(string)
    security_group_ids = optional(list(string))
    allowed_address_pairs = optional(list(object({
      ip_address  = string
      mac_address = optional(string)
    })))
    mac_address            = optional(string)
    floatingip_pool        = optional(any)
    floatingip_description = optional(string)
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_region"></a> [region](#input\_region)

Description: The region in which to create module resources.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Default set of module resources tags.

Type: `set(string)`

Default: `[]`

### <a name="input_cluster"></a> [cluster](#input\_cluster)

Description: Settings to create a scalable cluster of identical VMs.

`count` - count of VMs in the cluster.

`servergroup_name` - name of a server group. Requires `servergroup_policy` to be set. If not set it is assigned to `name` module variable.

`servergroup_policy` - server group policy. See `vkcs_compute_servergroup`'s `policy` argument for available values. If no specified the server group is not created.

`availability_zones` - list of availability zones to spread VMs. If no specified `availability_zone` must be set at the root level. If the list contains lesser elements that cluster.size, the elements are used for VMs in cycle.

Type:

```hcl
object({
    size               = number
    servergroup_name   = optional(string)
    servergroup_policy = optional(string)
    availability_zones = optional(list(string))
  })
```

Default: `null`

### <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone)

Description: The availability zone in which to create VM or cluster. Conflicts with `cluster.availability_zones`.

Type: `string`

Default: `null`

### <a name="input_flavor_name"></a> [flavor\_name](#input\_flavor\_name)

Description: The name of the desired flavor for the server. Required if `flavor_id` is empty.

Type: `string`

Default: `null`

### <a name="input_flavor_id"></a> [flavor\_id](#input\_flavor\_id)

Description: The flavor ID of the desired flavor for the server. Required if `flavor_name` is empty.

Type: `string`

Default: `null`

### <a name="input_cloud_monitoring"></a> [cloud\_monitoring](#input\_cloud\_monitoring)

Description: The settings of the cloud monitoring.

Type:

```hcl
object({
    script          = string
    service_user_id = string
  })
```

Default: `null`

### <a name="input_key_pair"></a> [key\_pair](#input\_key\_pair)

Description: The name of a key pair to put on the server.

Type: `string`

Default: `null`

### <a name="input_config_drive"></a> [config\_drive](#input\_config\_drive)

Description: Whether to use the config\_drive feature to configure the instance.

Type: `bool`

Default: `null`

### <a name="input_personality"></a> [personality](#input\_personality)

Description: Customize the personality of an instance by defining one or more files and their contents.

Type:

```hcl
list(object({
    content = string
    file    = string
  }))
```

Default: `null`

### <a name="input_user_data"></a> [user\_data](#input\_user\_data)

Description: The user data to provide when launching the instance.

Type: `string`

Default: `null`

### <a name="input_admin_pass"></a> [admin\_pass](#input\_admin\_pass)

Description: The administrative password to assign to the server.

Type: `string`

Default: `null`

### <a name="input_vendor_options"></a> [vendor\_options](#input\_vendor\_options)

Description: Map of additional vendor-specific options.

`ignore_resize_confirmation` is `true` by default.

Type:

```hcl
object({
    detach_ports_before_destroy = optional(bool)
    get_password_data           = optional(bool)
    ignore_resize_confirmation  = optional(bool)
  })
```

Default:

```json
{
  "ignore_resize_confirmation": true
}
```

### <a name="input_backup_plan"></a> [backup\_plan](#input\_backup\_plan)

Description: Configuration for backup plan.

See `vkcs_backup_plan` arguments. If name is not set it is assigned to `name` module variable.

Type:

```hcl
object({
    name               = optional(string)
    incremental_backup = bool
    schedule = object({
      date        = optional(list(string))
      every_hours = optional(number)
      time        = optional(string)
    })
    full_retention = optional(object({
      max_full_backup = number
    }))
    gfs_retention = optional(object({
      gfs_weekly  = number
      gfs_monthly = optional(number)
      gfs_yearly  = optional(number)
    }))
  })
```

Default:

```json
{
  "gfs_retention": {
    "gfs_monthly": 12,
    "gfs_weekly": 4,
    "gfs_yearly": 5
  },
  "incremental_backup": true,
  "schedule": {
    "date": [
      "Sa"
    ],
    "time": "22:00+03"
  }
}
```

## Outputs

The following outputs are exported:

### <a name="output_instances"></a> [instances](#output\_instances)

Description: List of the instances info.

### <a name="output_servergroup_id"></a> [servergroup\_id](#output\_servergroup\_id)

Description: Server group ID.

### <a name="output_backup_plan_id"></a> [backup\_plan\_id](#output\_backup\_plan\_id)

Description: Backup plan ID.
<!-- END_TF_DOCS -->