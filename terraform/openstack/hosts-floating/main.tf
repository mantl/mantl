variable auth_url { }
variable datacenter { default = "openstack" }
variable tenant_id { }
variable tenant_name { }
variable control_flavor_name { }
variable glusterfs_volume_size { default = "100" } # size is in gigabytes
variable resource_flavor_name { }
variable keypair_name { }
variable image_name { }
variable control_count {}
variable resource_count {}
variable security_groups { default = "default" }
variable floating_pool {}
variable external_net_id { }
variable subnet_cidr { default = "10.10.10.0/24" }
variable ip_version { default = "4" }
variable short_name { default = "mi" }
variable long_name { default = "microservices-infrastructure" }
variable ssh_user { default = "centos" }

provider "openstack" {
  auth_url	= "${ var.auth_url }"
  tenant_id	= "${ var.tenant_id }"
  tenant_name	= "${ var.tenant_name }"
}

resource "openstack_blockstorage_volume_v1" "mi-control-glusterfs" {
  name = "${ var.short_name }-control-glusterfs-${format("%02d", count.index+1) }"
  description = "${ var.short_name }-control-glusterfs-${format("%02d", count.index+1) }"
  size = "${ var.glusterfs_volume_size }"
  metadata = {
    usage = "container-volumes"
  }
  count = "${ var.control_count }"
}

resource "openstack_blockstorage_volume_v1" "mi-resource-glusterfs" {
  name = "${ var.short_name }-control-glusterfs-${format("%02d", count.index+1) }"
  description = "${ var.short_name }-control-glusterfs-${format("%02d", count.index+1) }"
  size = "${ var.glusterfs_volume_size }"
  metadata = {
    usage = "container-volumes"
  }
  count = "${ var.resource_count }"
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
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-control-glusterfs.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata              = {
                            dc = "${var.datacenter}"
                            role = "control"
                            ssh_user = "${ var.ssh_user }"
                          }
  count                 = "${ var.control_count }"
}

resource "openstack_compute_instance_v2" "resource" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.ms-resource-floatip.*.address, count.index) }"
  name                  = "${ var.short_name}-worker-${format("%03d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.resource_flavor_name }"
  security_groups       = [ "${ var.security_groups }" ]
  network               = { uuid = "${ openstack_networking_network_v2.ms-network.id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-resource-glusterfs.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata              = {
                            dc = "${var.datacenter}"
                            role = "worker"
                            ssh_user = "${ var.ssh_user }"
                          }
  count                 = "${ var.resource_count }"
}

resource "openstack_compute_floatingip_v2" "ms-control-floatip" {
  pool 	     = "${ var.floating_pool }"
  count      = "${ var.control_count }"
  depends_on = [ "openstack_networking_router_v2.ms-router",
                 "openstack_networking_network_v2.ms-network",
                 "openstack_networking_router_interface_v2.ms-router-interface" ]
}

resource "openstack_compute_floatingip_v2" "ms-resource-floatip" {
  pool       = "${ var.floating_pool }"
  count      = "${ var.resource_count }"
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
  value = "${join(\",\", openstack_compute_instance_v2.resource.*.access_ip_v4)}"
}
