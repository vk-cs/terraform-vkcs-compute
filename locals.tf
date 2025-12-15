locals {
  instance_count = try(var.cluster.size, 1)

  availability_zones = can(length(var.cluster.availability_zones)) ? var.cluster.availability_zones : [var.availability_zone]

  instance_availability_zones = [
    for i in range(local.instance_count) :
    local.availability_zones[i % length(local.availability_zones)]
  ]

  all_ports = flatten([
    for instance_idx in range(local.instance_count) : [
      for port_idx, port in var.ports : merge(port, {
        instance_idx = instance_idx,
        port_idx     = port_idx,
        port_key     = "${instance_idx}-${port_idx}"
      })
    ]
  ])

  all_volumes = flatten([
    for instance_idx in range(local.instance_count) : [
      for volume_idx, volume in var.volumes : merge(volume, {
        instance_idx = instance_idx,
        volume_idx   = volume_idx,
        volume_key   = "${instance_idx}-${volume_idx}"
      })
    ]
  ])
}
