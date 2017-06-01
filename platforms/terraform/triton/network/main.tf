# input variables
variable short_name { }
variable end_ip { default = "10.0.3.250" }
variable gateway { default = "10.0.0.1" }
variable start_ip { default = "10.0.0.5" }
variable subnet { default = "10.0.0.0/22" }
variable vlan_id { default = "2" }

resource "triton_vlan" "vlan" {
  vlan_id = "${var.vlan_id}"
  name = "${var.short_name}"
  description = "mantl cluster: ${var.short_name}"
}

resource "triton_fabric" "network" {
  name = "${var.short_name}"
  description = "mantl cluster: ${var.short_name}"
  vlan_id = "${triton_vlan.vlan.vlan_id}"

  subnet = "${var.subnet}"
  gateway = "${var.gateway}"
  provision_start_ip = "${var.start_ip}"
  provision_end_ip = "${var.end_ip}"

  resolvers = ["8.8.8.8", "8.8.4.4"]
}

output "network_id" {
  value = "${triton_fabric.network.id}"
}
