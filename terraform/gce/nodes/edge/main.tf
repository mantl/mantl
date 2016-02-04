# edge node variables
variable "edge_type" {default = "n1-standard-1"}
variable "edge_count" {default = 2}
variable "edge_volume_size" {default = "10"} # size is in gigabytes
variable "edge_data_volume_size" {default = "20"} # size is in gigabytes
# variables needed for gce
variable "datacenter" {}
variable "image" {}
variable "long_name" {}
variable "network_name" {}
variable "short_name" {}
variable "ssh_key" {}
variable "ssh_user" {}
variable "zones" {}


# Instances
resource "google_compute_disk" "mantl-edge-lvm" {
  name = "${var.short_name}-edge-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${element(split(",", var.zones), count.index)}"
  size = "${var.edge_data_volume_size}"
  count = "${var.edge_count}"
}

resource "google_compute_instance" "mantl-edge-nodes" {
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}"
  description = "${var.long_name} edge node #${format("%02d", count.index+1)}"
  machine_type = "${var.edge_type}"
  zone = "${element(split(",", var.zones), count.index)}"
  can_ip_forward = false
  tags = ["${var.short_name}", "edge"]

  disk {
    image = "${var.image}"
    size = "${var.edge_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.mantl-edge-lvm.*.name, count.index)}"
    auto_delete = false

    # make disk available as "/dev/disk/by-id/google-lvm"
    # NOTE: "google-" prefix is auto added
    device_name = "lvm"
  }

  network_interface {
    network = "${var.network_name}"
    access_config {}
  }

  metadata {
    dc = "${var.datacenter}"
    role = "edge"
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.edge_count}"

  provisioner "remote-exec" {
    script = "./terraform/gce/disk.sh"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
    }
  }
}

output "edge_ips" {
  value = "${join(\",\", google_compute_instance.mantl-edge-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}
