variable "region" {
  type        = string
  description = "The region in which to create the server instance."
  default     = null
}

variable "name" {
  type        = string
  description = "Name for the compute resources."
}

variable "tags" {
  type        = set(string)
  description = "A set of string tags for the instance."
  default     = []
}

variable "instances_count" {
  type        = number
  description = "Number of VM instances to create"
}

variable "server_group" {
  type = object({
    name     = string
    policies = optional(set(string))
  })

  description = "Configuration for creating a server group"
}

variable "enable_backup_plan" {
  type        = bool
  description = <<-EOT
  Enables or disables creation of backup plan.
  If `true`: Creates backup plan using custom or default settings.
  If `false`: No backup plan is created.
  EOT
  default     = true
}

variable "backup_plan" {
  type = object({
    name               = string
    incremental_backup = optional(bool, false)
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
  When `enable_backup_plan = true`:
  - If this variable is set: Uses provided configuration
  - If this variable is null: Uses default backup plan configuration
  When `enable_backup_plan = false`: This variable is ignored
  See `vkcs_backup_plan` arguments.
  EOT
  default = {
    name = "default-backup-plan"
    schedule = {
      date = ["Mo"],
      time = "04:00+03"
    }
    full_retention = {
      max_full_backup = 25
    }
  }
}

variable "boot_volume" {
  type = object({
    tags        = list(string)
    name        = string
    description = string
    type        = string
    size        = number
    image_id    = string
  })
  description = "Configuration for the boot volume."
}

variable "data_volumes" {
  type = list(object({
    tags        = list(string)
    name        = string
    description = string
    type        = string
    size        = number
  }))
  description = "List of data volume configurations."
  default     = null
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for spreading instances."

  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "At least one availability zone must be specified."
  }
}

variable "flavor_name" {
  type        = string
  description = "The name of the desired flavor for the server. Required if flavor_id is empty."
  default     = null
}

variable "flavor_id" {
  type        = string
  description = "The flavor ID of the desired flavor for the server. Required if flavor_name is empty."
  default     = null
}

variable "key_pair" {
  type        = string
  description = "The name of a key pair to put on the server."
  default     = null
}

variable "admin_pass" {
  type        = string
  default     = null
  description = "The administrative password to assign to the server."
  sensitive   = true
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

variable "cloud_monitoring" {
  type = object({
    script          = string
    service_user_id = string
  })
  description = "The settings of the cloud monitoring."
  default     = null
}

variable "networks" {
  type = list(object({
    access_network = optional(bool)
    fixed_ip_v4    = optional(string)
    name           = optional(string)
    port           = optional(string)
    uuid           = optional(string)
  }))
  description = "An array of one or more networks to attach to the instance."
  default     = []
}

variable "vendor_options" {
  type = object({
    detach_ports_before_destroy = optional(bool)
    get_password_data           = optional(bool)
    ignore_resize_confirmation  = optional(bool)
  })
  description = "Map of additional vendor-specific options."
  default     = null
}





