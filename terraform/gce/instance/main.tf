variable "count" {default = "3"}
variable "machine_type" {default = "n1-standard-1"}
variable "volume_size" {default = "20"} # size is in gigabytes
variable "data_volume_size" {default = "20"} # size is in gigabytes
variable "datacenter" {}
variable "image" {}
variable "role" {}
variable "network_name" {}
variable "short_name" {}
variable "ssh_key" {}
variable "ssh_user" {}
variable "zones" {}


# Instances
resource "google_compute_disk" "disk" {
  name = "${var.short_name}-${var.role}-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${element(split(",", var.zones), count.index)}"
  size = "${var.data_volume_size}"
  count = "${var.count}"
}

resource "google_compute_instance" "instance" {
  name = "${var.short_name}-${var.role}-${format("%02d", count.index+1)}"
  description = "${var.short_name} ${var.role} node #${format("%02d", count.index+1)}"
  machine_type = "${var.machine_type}"
  zone = "${element(split(",", var.zones), count.index)}"
  can_ip_forward = false
  tags = ["${var.short_name}", "${var.role}"]

  disk {
    image = "${var.image}"
    size = "${var.volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.disk.*.name, count.index)}"
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
    role = "${var.role}"
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.count}"

  provisioner "remote-exec" {
    script = "./terraform/gce/disk.sh"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
    }
  }
}



output "gce_ips" {
  value = "${join(\",\", google_compute_instance.instance.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}

output "instances" {
  value = "${join(",", google_compute_instance.instance.*.self_link)}"
}
