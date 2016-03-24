# WARNING: This module has been deprecated as of Mantl 1.0

variable auth_url { }
variable control_count {}
variable control_flavor_name { }
variable control_data_volume_size { default = "20" } # size is in gigabytes
variable edge_data_volume_size { default = "20" } # size is in gigabytes
variable worker_data_volume_size { default = "100" } # size is in gigabytes
variable datacenter { default = "openstack" }
variable edge_count { }
variable edge_flavor_name { }
variable image_name { }
variable keypair_name { }
variable long_name { default = "mantl" }
variable net_id { }
variable worker_count {}
variable worker_flavor_name { }
variable security_groups { default = "default" }
variable short_name { default = "mantl" }
variable ssh_user { default = "centos" }
variable tenant_id { }
variable tenant_name { }

provider "openstack" {
  auth_url = "${ var.auth_url }"
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
  name = "${ var.short_name}-control-${format("%02d", count.index+1) }"
  key_pair = "${ var.keypair_name }"
  image_name = "${ var.image_name }"
  flavor_name = "${ var.control_flavor_name }"
  security_groups = [ "${ var.security_groups }" ]
  network = { uuid  = "${ var.net_id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-control-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata = {
    dc = "${var.datacenter}"
    role = "control"
    ssh_user = "${ var.ssh_user }"
  }
  count = "${ var.control_count }"
}

resource "openstack_compute_instance_v2" "worker" {
  name = "${ var.short_name}-worker-${format("%03d", count.index+1) }"
  key_pair = "${ var.keypair_name }"
  image_name = "${ var.image_name }"
  flavor_name = "${ var.worker_flavor_name }"
  security_groups = [ "${ var.security_groups }" ]
  network = { uuid = "${ var.net_id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-worker-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata = {
    dc = "${var.datacenter}"
    role = "worker"
    ssh_user = "${ var.ssh_user }"
  }
  count = "${ var.worker_count }"
}

resource "openstack_compute_instance_v2" "edge" {
  name = "${ var.short_name}-edge-${format("%02d", count.index+1) }"
  key_pair = "${ var.keypair_name }"
  image_name = "${ var.image_name }"
  flavor_name = "${ var.edge_flavor_name }"
  security_groups = [ "${ var.security_groups }" ]
  network = { uuid = "${ var.net_id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-edge-lvm.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata = {
    dc = "${var.datacenter}"
    role = "edge"
    ssh_user = "${ var.ssh_user }"
  }
  count = "${ var.edge_count }"
}

output "control_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.control.*.access_ip_v4)}"
}

output "worker_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.worker.*.access_ip_v4)}"
}

output "edge_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.edge.*.access_ip_v4)}"
}
