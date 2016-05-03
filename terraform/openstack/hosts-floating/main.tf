# WARNING: This module has been deprecated as of Mantl 1.0

variable auth_url { }
variable control_count {}
variable control_flavor_name { }
variable control_data_volume_size { default = "20" } # size is in gigabytes
variable edge_data_volume_size { default = "20" } # size is in gigabytes
variable worker_data_volume_size { default = "100" } # size is in gigabytes
variable datacenter { default = "openstack" }
variable edge_count {}
variable edge_flavor_name {}
variable external_net_id { }
variable floating_pool {}
variable image_name { }
variable ip_version { default = "4" }
variable keypair_name { }
variable long_name { default = "mantl" }
variable worker_count {}
variable kubeworker_count { default = "0"}
variable worker_flavor_name { }
variable security_groups { default = "default" }
variable short_name { default = "mantl" }
variable ssh_user { default = "centos" }
variable subnet_cidr { default = "10.10.10.0/24" }
variable tenant_id { }
variable tenant_name { }

provider "openstack" {
  auth_url	= "${ var.auth_url }"
  tenant_id	= "${ var.tenant_id }"
  tenant_name	= "${ var.tenant_name }"
}

resource "openstack_blockstorage_volume_v1" "mi-control-lvm" {
  name = "${ var.short_name }-control-lvm-${format("%02d", count.index+1) }"
  description = "${ var.short_name }-control-lvm-${format("%02d", count.index+1) }"
  size = "${ var.control_data_volume_size }"
  metadata = {
    usage = "container-volumes"
  }
  count = "${ var.control_count }"
}

resource "openstack_blockstorage_volume_v1" "mi-worker-lvm" {
  name = "${ var.short_name }-worker-lvm-${format("%02d", count.index+1) }"
  description = "${ var.short_name }-worker-lvm-${format("%02d", count.index+1) }"
  size = "${ var.worker_data_volume_size }"
  metadata = {
    usage = "container-volumes"
  }
  count = "${ var.worker_count }"
}

resource "openstack_blockstorage_volume_v1" "mi-kubeworker-lvm" {
  name = "${ var.short_name }-kubeworker-lvm-${format("%02d", count.index+1) }"
  description = "${ var.short_name }-kubeworker-lvm-${format("%02d", count.index+1) }"
  size = "${ var.worker_data_volume_size }"
  metadata = {
    usage = "container-volumes"
  }
  count = "${ var.kubeworker_count }"
}

resource "openstack_blockstorage_volume_v1" "mi-edge-lvm" {
  name = "${ var.short_name }-edge-lvm-${format("%02d", count.index+1) }"
  description = "${ var.short_name }-edge-lvm-${format("%02d", count.index+1) }"
  size = "${ var.edge_data_volume_size }"
  metadata = {
    usage = "container-volumes"
  }
  count = "${ var.edge_count }"
}

resource "openstack_compute_instance_v2" "control" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.ms-control-floatip.*.address, count.index) }"
  name                  = "${ var.short_name}-control-${format("%02d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.control_flavor_name }"
  security_groups       = [ "${ var.security_groups }" ]
  network               = { uuid = "${ openstack_networking_network_v2.ms-network.id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-control-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata              = {
                            dc = "${var.datacenter}"
                            role = "control"
                            ssh_user = "${ var.ssh_user }"
                          }
  count                 = "${ var.control_count }"
}

resource "openstack_compute_instance_v2" "worker" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.ms-worker-floatip.*.address, count.index) }"
  name                  = "${ var.short_name}-worker-${format("%03d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.worker_flavor_name }"
  security_groups       = [ "${ var.security_groups }" ]
  network               = { uuid = "${ openstack_networking_network_v2.ms-network.id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-worker-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata              = {
                            dc = "${var.datacenter}"
                            role = "worker"
                            ssh_user = "${ var.ssh_user }"
                          }
  count                 = "${ var.worker_count }"
}

resource "openstack_compute_instance_v2" "kubeworker" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.ms-kubeworker-floatip.*.address, count.index) }"
  name                  = "${ var.short_name}-kubeworker-${format("%03d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.worker_flavor_name }"
  security_groups       = [ "${ var.security_groups }" ]
  network               = { uuid = "${ openstack_networking_network_v2.ms-network.id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-kubeworker-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata              = {
                            dc = "${var.datacenter}"
                            role = "kubeworker"
                            ssh_user = "${ var.ssh_user }"
                          }
  count                 = "${ var.kubeworker_count }"
}

resource "openstack_compute_instance_v2" "edge" {
  floating_ip     = "${ element(openstack_compute_floatingip_v2.ms-edge-floatip.*.address, count.index) }"
  name            = "${var.short_name}-edge-${format("%02d", count.index+1)}"
  key_pair        = "${var.keypair_name}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.edge_flavor_name}"
  security_groups = [ "${var.security_groups}" ]
  network         = { uuid = "${openstack_networking_network_v2.ms-network.id}" }

  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-edge-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }

  metadata = {
    dc = "${var.datacenter}"
    role = "edge"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.edge_count}"
}

resource "openstack_compute_floatingip_v2" "ms-control-floatip" {
  pool 	     = "${ var.floating_pool }"
  count      = "${ var.control_count }"
  depends_on = [ "openstack_networking_router_v2.ms-router",
                 "openstack_networking_network_v2.ms-network",
                 "openstack_networking_router_interface_v2.ms-router-interface" ]
}

resource "openstack_compute_floatingip_v2" "ms-worker-floatip" {
  pool       = "${ var.floating_pool }"
  count      = "${ var.worker_count }"
  depends_on = [ "openstack_networking_router_v2.ms-router",
                 "openstack_networking_network_v2.ms-network",
                 "openstack_networking_router_interface_v2.ms-router-interface" ]
}

resource "openstack_compute_floatingip_v2" "ms-kubeworker-floatip" {
  pool       = "${ var.floating_pool }"
  count      = "${ var.kubeworker_count }"
  depends_on = [ "openstack_networking_router_v2.ms-router",
                 "openstack_networking_network_v2.ms-network",
                 "openstack_networking_router_interface_v2.ms-router-interface" ]
}

resource "openstack_compute_floatingip_v2" "ms-edge-floatip" {
  pool       = "${var.floating_pool}"
  count      = "${var.edge_count}"
  depends_on = [ "openstack_networking_router_v2.ms-router",
                 "openstack_networking_network_v2.ms-network",
                 "openstack_networking_router_interface_v2.ms-router-interface" ]
}

resource "openstack_networking_network_v2" "ms-network" {
  name = "${ var.short_name }-network"
}

resource "openstack_networking_subnet_v2" "ms-subnet" {
  name          ="${ var.short_name }-subnet"
  network_id    = "${ openstack_networking_network_v2.ms-network.id }"
  cidr          = "${ var.subnet_cidr }"
  ip_version    = "${ var.ip_version }"
}

resource "openstack_networking_router_v2" "ms-router" {
  name             = "${ var.short_name }-router"
  external_gateway = "${ var.external_net_id }"
}

resource "openstack_networking_router_interface_v2" "ms-router-interface" {
  router_id = "${ openstack_networking_router_v2.ms-router.id }"
  subnet_id = "${ openstack_networking_subnet_v2.ms-subnet.id }"
}

output "control_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.control.*.access_ip_v4)}"
}

output "worker_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.worker.*.access_ip_v4)}"
}

output "kubeworker_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.kubeworker.*.access_ip_v4)}"
}

output "edge_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.edge.*.access_ip_v4)}"
}
