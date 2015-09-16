variable auth_url { }
variable control_count {}
variable control_flavor_name { }
variable datacenter { default = "openstack" }
variable glusterfs_volume_size { default = "100" } # size is in gigabytes
variable image_name { }
variable keypair_name { }
variable long_name { default = "microservices-infrastructure" }
variable net_id { }
variable resource_count {}
variable resource_flavor_name { }
variable security_groups { default = "default" }
variable short_name { default = "mi" }
variable ssh_user { default = "centos" }
variable tenant_id { }
variable tenant_name { }

provider "openstack" {
  auth_url = "${ var.auth_url }"
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

resource "openstack_compute_instance_v2" "control" {
  name = "${ var.short_name}-control-${format("%02d", count.index+1) }"
  key_pair = "${ var.keypair_name }"
  image_name = "${ var.image_name }"
  flavor_name = "${ var.control_flavor_name }"
  security_groups = [ "${ var.security_groups }" ]
  network = { uuid  = "${ var.net_id }" }
  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.mi-control-glusterfs.*.id, count.index)}"
    device = "/dev/vdb"
  }
  metadata = {
    dc = "${var.datacenter}"
    role = "control"
    ssh_user = "${ var.ssh_user }"
  }
  count = "${ var.control_count }"
}

resource "openstack_compute_instance_v2" "resource" {
  name = "${ var.short_name}-worker-${format("%03d", count.index+1) }"
  key_pair = "${ var.keypair_name }"
  image_name = "${ var.image_name }"
  flavor_name = "${ var.resource_flavor_name }"
  security_groups = [ "${ var.security_groups }" ]
  network = { uuid = "${ var.net_id }" }
  metadata = {
    dc = "${var.datacenter}"
    role = "worker"
    ssh_user = "${ var.ssh_user }"
  }
  count = "${ var.resource_count }"
}

output "control_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.control.*.access_ip_v4)}"
}

output "worker_ips" {
  value = "${join(\",\", openstack_compute_instance_v2.resource.*.access_ip_v4)}"
}
