variable "region" {
  type        = string
  description = "The region in which to create module resources."
  default     = null
}

variable "tags" {
  type        = set(string)
  description = "Default set of module resources tags."
  default     = []
}

variable "name" {
  type        = string
  description = "Default name for module resources. Used when name is not specified for a resource."

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name must not be empty."
  }
}

variable "cluster" {
  type = object({
    size               = number
    servergroup_name   = optional(string)
    servergroup_policy = optional(string)
    availability_zones = optional(list(string))
  })
  description = <<-EOT
  Settings to create a scalable cluster of identical VMs.

  `count` - count of VMs in the cluster.

  `servergroup_name` - name of a server group. Requires `servergroup_policy` to be set. If not set it is assigned to `name` module variable.

  `servergroup_policy` - server group policy. See `vkcs_compute_servergroup`'s `policy` argument for available values. If no specified the server group is not created.

  `availability_zones` - list of availability zones to spread VMs. If no specified `availability_zone` must be set at the root level. If the list contains lesser elements that cluster.size, the elements are used for VMs in cycle.
  EOT
  default     = null

  validation {
    condition     = var.cluster == null || var.cluster.size >= 1
    error_message = "Count of cluster VMs must be 1 or more."
  }
  validation {
    condition     = var.cluster == null || var.cluster.servergroup_name == null || var.cluster.servergroup_policy != null
    error_message = "servergroup_policy must be specified if servergroup_name is set."
  }
  validation {
    condition     = try(trimspace(var.cluster.servergroup_name), "_") != ""
    error_message = "servergroup_name must not be empty if specified."
  }
  validation {
    condition     = var.availability_zone != null || var.cluster != null && try(length(var.cluster.availability_zones), 0) > 0
    error_message = "One of availability_zone and cluster.availability_zones must be specified. And in the last case cluster.availability_zones must not be empty."
  }
  validation {
    condition     = var.availability_zone == null || var.cluster == null || var.cluster.availability_zones == null
    error_message = "Only one of availability_zone and cluster.availability_zones must be specified."
  }
}

variable "availability_zone" {
  type        = string
  description = "The availability zone in which to create VM or cluster. Conflicts with `cluster.availability_zones`."
  default     = null
}

variable "flavor_name" {
  type        = string
  description = "The name of the desired flavor for the server. Required if `flavor_id` is empty."
  default     = null
}

variable "flavor_id" {
  type        = string
  description = "The flavor ID of the desired flavor for the server. Required if `flavor_name` is empty."
  default     = null
}

variable "volumes" {
  type = list(object({
    name        = optional(string)
    description = optional(string)
    type        = string
    size        = number
    image_id    = optional(string)
  }))
  description = <<-EOT
  Configuration for the boot volume.
  See `vkcs_blockstorage_volume` arguments for details. If name is not set it is assigned to `name` module variable.
  At least one volume must be specified. The first volume requires `image_id`.
  EOT

  validation {
    condition     = length(var.volumes) > 0
    error_message = "Specify at least one volume."
  }
  validation {
    condition     = length(var.volumes[0]) == 0 || var.volumes[0].image_id != null
    error_message = "Specify `image_id` for the first volume."
  }
  validation {
    condition     = alltrue([for v in var.volumes : try(trimspace(v.name), "_") != ""])
    error_message = "Volume name must not be empty if specified."
  }
}

variable "ports" {
  type = list(object({
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
  description = <<-EOT
  List of ports to create and attach to instances.

  See `vkcs_networking_port` arguments for details. If name is not set it is assigned to `name` module variable.

  `subnet_id` and `ip_address` - arguments for the first `fixed_ips` element in `vkcs_networking_port`. Next elements are not supported by the module.

  `floatingip_pool` - allocate and associate floating IP to the port. Specify external network name or set `true` if the only external netwrok is available in the project.

  `floatingip_description` - `description` argument for `vkcs_networking_floatingip` resource.

  At least one port must be specified.
  EOT

  validation {
    condition     = length(var.ports) > 0
    error_message = "Specify at least one port."
  }
  validation {
    condition     = alltrue([for p in var.ports : p.ip_address == null || p.subnet_id != null])
    error_message = "subnet_id is required to specify ip_address."
  }
  validation {
    condition     = alltrue([for p in var.ports : try(trimspace(p.name), "_") != ""])
    error_message = "Port name must not be empty if specified."
  }
  validation {
    condition = alltrue([for p in var.ports : (
      p.floatingip_pool == null || p.floatingip_pool == false || p.floatingip_pool == true ||
      can(trimspace(p.floatingip_pool))
    )])
    error_message = "floatingip_pool must be null, bool or string."
  }
  validation {
    condition = alltrue([for p in var.ports : (
      p.floatingip_description == null || p.floatingip_pool != null && p.floatingip_pool != false
    )])
    error_message = "floatingip_pool must be specified if floatingip_description is set."
  }
}

variable "cloud_monitoring" {
  type = object({
    script          = string
    service_user_id = string
  })
  description = "The settings of the cloud monitoring."
  default     = null
}

variable "key_pair" {
  type        = string
  description = "The name of a key pair to put on the server."
  default     = null
}

variable "config_drive" {
  type        = bool
  description = "Whether to use the config_drive feature to configure the instance."
  default     = null
}

variable "personality" {
  type = list(object({
    content = string
    file    = string
  }))
  description = "Customize the personality of an instance by defining one or more files and their contents."
  default     = null
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance."
  default     = null
}

variable "admin_pass" {
  type        = string
  default     = null
  description = "The administrative password to assign to the server."
  sensitive   = true
}

variable "vendor_options" {
  type = object({
    detach_ports_before_destroy = optional(bool)
    get_password_data           = optional(bool)
    ignore_resize_confirmation  = optional(bool)
  })
  description = <<-EOT
  Map of additional vendor-specific options.

  `ignore_resize_confirmation` is `true` by default.
  EOT
  default = {
    ignore_resize_confirmation = true
  }
}

variable "backup_plan" {
  type = object({
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
  description = <<-EOT
  Configuration for backup plan.

  See `vkcs_backup_plan` arguments. If name is not set it is assigned to `name` module variable.
  EOT
  default = {
    incremental_backup = true
    schedule = {
      date = ["Sa"]
      time = "22:00+03"
    }
    gfs_retention = {
      gfs_weekly  = 4
      gfs_monthly = 12
      gfs_yearly  = 5
    }
  }

  validation {
    condition     = try(trimspace(var.backup_plan.name) != "", true)
    error_message = "Backup plan name must not be empty if specified."
  }
}
