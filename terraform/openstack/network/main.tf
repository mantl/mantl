variable name { default = "mantl" }
variable subnet_cidr {}
variable ip_version { default = "4" }
variable external_net_uuid {}
variable admin_state_up { default = "true" } 

resource "openstack_networking_network_v2" "network" {
  name = "${var.name}-network"
  admin_state_up = "${var.admin_state_up}"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name = "${var.name}-subnet"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr = "${var.subnet_cidr}"
  ip_version = "${var.ip_version}"
}

resource "openstack_networking_router_v2" "router" {
  name = "${var.name}-router"
  external_gateway = "${var.external_net_uuid}"
}

resource "openstack_networking_router_interface_v2" "router-interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}

output "network_uuid" {
  value = "${openstack_networking_network_v2.network.id}"
}
