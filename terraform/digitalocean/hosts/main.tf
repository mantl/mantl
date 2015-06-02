# input variables
variable short_name { default = "mi" }
variable image_name { default = "centos-7-0-x64" }
variable region_name { default = "nyc3" }
variable control_count { default = 1 }
variable worker_count { default = 3 }
variable control_size { default = "1GB" }
variable worker_size { default = "4GB" }
variable ssh_key { }

# create resources
resource "digitalocean_droplet" "control" {
  count = "${var.control_count}"
  name = "${var.short_name}-control-${format("%02d", count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  size = "${var.control_size}"
  ssh_keys = ["${vars.ssh_key}"]
  user_data = {
    role = "control"
  }
}

resource "digitalocean_droplet" "worker" {
  count = "${var.worker_count}"
  name = "${var.short_name}-control-${format("%03d", count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region_name}"
  size = "${var.worker_size}"
  ssh_keys = ["${vars.ssh_key}"]
  user_data = {
    role = "worker"
  }
}
