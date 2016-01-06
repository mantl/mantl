variable "control_count" {default = "3"}
variable "control_type" {default = "n1-standard-1"}
variable "control_volume_size" {default = "20"} # size is in gigabytes
variable "control_data_volume_size" {default = "20"} # size is in gigabytes

variable "datacenter" {}
variable "image" {}
variable "long_name" {}
variable "network_name" {}
variable "short_name" {}
variable "ssh_key" {}
variable "ssh_user" {}
variable "zones" {}


# Instances
resource "google_compute_disk" "mantl-control-lvm" {
  name = "${var.short_name}-control-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${element(split(",", var.zones), count.index)}"
  size = "${var.control_data_volume_size}"
  count = "${var.control_count}"
}

resource "google_compute_instance" "mantl-control-nodes" {
  name = "${var.short_name}-control-${format("%02d", count.index+1)}"
  description = "${var.long_name} control node #${format("%02d", count.index+1)}"
  machine_type = "${var.control_type}"
  zone = "${element(split(",", var.zones), count.index)}"
  can_ip_forward = false
  tags = ["${var.short_name}", "control"]

  disk {
    image = "${var.image}"
    size = "${var.control_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.mantl-control-lvm.*.name, count.index)}"
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
    role = "control"
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.control_count}"

  provisioner "remote-exec" {
    script = "./terraform/gce/disk.sh"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
    }
  }
}



output "control_ips" {
  value = "${join(\",\", google_compute_instance.mantl-control-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}