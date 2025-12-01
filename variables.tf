variable "instances_count" {
  type        = number
  description = "Number of VM instances to create"
}

variable "server_group" {
  type = object({
    name        = string
    policies    = optional(set(string))
    region      = optional(string)
    value_specs = optional(map(string))
  })

  description = "Configuration for creating a server group"
}

variable "backup" {
  type = object({
    name = string
    schedule = object({
      date        = optional(list(string))
      every_hours = optional(number)
      time        = optional(string)
    })
    max_full_backup = optional(string)
    provider_name   = optional(string)
  })
  description = "Configuration for backup plan. If null, backup plan will not be created"
  default     = null
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

variable "region" {
  type        = string
  description = "The region in which to create the server instance."
  default     = null
}

variable "tags" {
  type        = set(string)
  description = "A set of string tags for the instance."
  default     = []
}

variable "name" {
  type        = string
  description = "Name for the compute resources."
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





