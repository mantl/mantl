variable datacenter { default = "openstack" }
variable floating_ips { default = "" }
variable blockstorage_metadata_attached_mode { default = "rw" }
variable blockstorage_metadata_readonly { default = "False" }
variable count  {}
variable count_offset { default = 0 } #start numbering from X
variable count_format { default = "%02d" } #server number format (-01, -02, etc.)
variable flavor_name {}
variable image_name {}
variable keypair_name {}
variable name { default = "mantl" }
variable network_uuid {}
variable role { default = "instance" }
variable security_groups { default = "default" }
variable ssh_user { default = "cloud-user" }
variable volume_size { default = 20 }
variable volume_device { default = "/dev/vdb" }
variable user_data { default = "" }

resource "openstack_blockstorage_volume_v1" "blockstorage" {
  name = "${var.name}-${format(var.count_format, var.count_offset+count.index+1) }"
  description = "${var.name}-${format(var.count_format, var.count_offset+count.index+1) }"
  size = "${var.volume_size}"
  metadata = {
    attached_mode = "${var.blockstorage_metadata_attached_mode}"
    readonly = "${var.blockstorage_metadata_readonly}"
    usage = "${var.name}-${var.role}-blockstorage"
  }
  count = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  floating_ip = "${ element(split(",", var.floating_ips), count.index) }"
  name = "${var.name}-${var.role}-${format(var.count_format, var.count_offset+count.index+1)}"
  key_pair = "${var.keypair_name}"
  image_name = "${var.image_name}"
  flavor_name = "${var.flavor_name}"
  security_groups  = [ "${ var.security_groups }" ]

  network  = { 
    uuid = "${var.network_uuid}" 
  }

  volume = {
    volume_id = "${element(openstack_blockstorage_volume_v1.blockstorage.*.id, count.index)}"
    device = "${var.volume_device}"
  }

  metadata = {
    dc = "${var.datacenter}"
    role = "${var.role}"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.count}"

  user_data = "${var.user_data}"
}

output hostname_list {
  value = "${join(",", openstack_compute_instance_v2.instance.*.name)}"
}

output ip_v4_list {
  value = "${join(",", openstack_compute_instance_v2.instance.*.access_ip_v4)}"
}
