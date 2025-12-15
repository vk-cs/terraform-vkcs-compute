data "vkcs_networking_network" "networks" {
  for_each = { for idx, port in var.ports : idx => port.network_id }

  region = var.region
  id     = each.value
}

data "vkcs_networking_network" "pools" {
  for_each = {
    for idx, port in var.ports : idx => data.vkcs_networking_network.networks[idx]
    if port.floatingip_pool == true
  }

  region   = var.region
  sdn      = each.value.sdn
  # should be just true but this is workaround of TF bug:
  # it evaluates this data source even if networks datasource evaluatiion is postponed to apply stage
  # in this case TF passes null into sdn argument
  external = each.value.id != null ? true : true
}
