variable "name" { default = "mantl" }
variable "datacenter" { default = "mantl" }
variable "image_name" { default = "centos-7-2-x64" }
variable "region" { default = "nyc3" } # Must have metadata support
# Hosts
variable "count" { default = "2" }
variable "count_format" { default = "%03d" }
variable "size" { default = "4gb" }
variable "role" {}
variable "keypair_id" { }

resource "digitalocean_droplet" "instance" {
  count = "${var.count}"
  name = "${var.name}-${var.role}-${format(var.count_format, count.index+1)}"
  image = "${var.image_name}"
  region = "${var.region}"
  size = "${var.size}"
  ssh_keys = ["${var.keypair_id}"]
  user_data = "{\"role\":\"${var.role}\",\"dc\":\"${var.datacenter}\"}"
}

output "droplet_ids" {
  value = "${join(",", digitalocean_droplet.instance.*.id)}"
}

output "droplet_ips" {
  value = "${join(",", digitalocean_droplet.instance.*.ipv4_address)}"
}
