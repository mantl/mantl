# input variables
variable datacenter { default = "mantl" }
variable image_name { default = "centos-7-2-x64" }
variable region_name { default = "nyc3" }
variable name { default = "mantl" }
variable ssh_key { }
# Hosts
variable control_count { default = 3 }
variable control_size { default = "4gb" }
variable worker_count { default = 3 }
variable worker_size { default = "4gb" }
variable edge_count { default = 2 }
variable edge_size { default = "2gb" }
variable kubeworker_count { default = 0 }

# create resources
resource "digitalocean_droplet" "control" {
  count = "${var.control_count}"
  name = "${var.name}-control-${format("%02d", count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  size = "${var.control_size}"
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"control\",\"dc\":\"${var.datacenter}\"}"
}

resource "digitalocean_droplet" "worker" {
  count = "${var.worker_count}"
  name = "${var.name}-worker-${format("%03d", count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  size = "${var.worker_size}"
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"worker\",\"dc\":\"${var.datacenter}\"}"
}

resource "digitalocean_droplet" "kubeworker" {
  count = "${var.kubeworker_count}"
  name = "${var.name}-kubeworker-${format("%03d", count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  size = "${var.worker_size}"
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"kubeworker\",\"dc\":\"${var.datacenter}\"}"
}

resource "digitalocean_droplet" "edge" {
  count = "${var.edge_count}"
  name = "${var.name}-edge-${format("%02d", count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  size = "${var.edge_size}"
  ssh_keys = ["${var.ssh_key}"]
  user_data = "{\"role\":\"edge\",\"dc\":\"${var.datacenter}\"}"
}

output "control_ips" {
  value = "${join(\",\", digitalocean_droplet.control.*.ipv4_address)}"
}

output "worker_ips" {
  value = "${join(\",\", digitalocean_droplet.worker.*.ipv4_address)}"
}

output "kubeworker_ips" {
  value = "${join(\",\", digitalocean_droplet.kubeworker.*.ipv4_address)}"
}

output "edge_ips" {
  value = "${join(\",\", digitalocean_droplet.edge.*.ipv4_address)}"
}
