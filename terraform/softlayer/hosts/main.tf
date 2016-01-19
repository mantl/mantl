# input variables
variable control_count { default = 1 }
variable control_size { default = 4096 }
variable datacenter { default = "mi" }
variable domain { default = "example.com" }
variable edge_count { default = 2 }
variable edge_size { default = 4096 }
variable image_name { default = "CENTOS_7_64" }
variable region_name { default = "ams01" }
variable short_name { default = "mi" }
variable ssh_key { }
variable worker_count { default = 3 }
variable worker_size { default = 4096 }

# create resources
resource "softlayer_virtualserver" "control" {
  count = "${var.control_count}"
  name = "${var.short_name}-control-${format("%02d", count.index+1)}"
  domain = "${var.domain}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  ram = "${var.control_size}"
  cpu = 1
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"control\",\"dc\":\"${var.datacenter}\"}"
}

resource "softlayer_virtualserver" "worker" {
  count = "${var.worker_count}"
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}"
  domain = "${var.domain}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  ram = "${var.worker_size}"
  cpu = 1
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"worker\",\"dc\":\"${var.datacenter}\"}"
}

resource "softlayer_virtualserver" "edge" {
  count = "${var.edge_count}"
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}"
  domain = "${var.domain}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  ram = "${var.edge_size}"
  cpu = 1
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"edge\",\"dc\":\"${var.datacenter}\"}"
}

output "control_ips" {
  value = "${join(\",\", softlayer_virtualserver.control.*.ipv4_address)}"
}

output "worker_ips" {
  value = "${join(\",\", softlayer_virtualserver.worker.*.ipv4_address)}"
}

output "edge_ips" {
  value = "${join(\",\", softlayer_virtualserver.edge.*.ipv4_address)}"
}
