locals {
  instance_availability_zones = [
    for i in range(var.instances_count) :
    var.availability_zones[i % length(var.availability_zones)]
  ]
}