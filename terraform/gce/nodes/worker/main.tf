# variables for worker nodes
variable "worker_volume_size" {default = "20"} # size is in gigabytes
variable "worker_data_volume_size" {default = "100"} # size is in gigabytes
variable "worker_count" {default = 1}
variable "worker_type" {default = "n1-highcpu-2"}
# variables needed for gce
variable "datacenter" {}
variable "image" {}
variable "long_name" {}
variable "network_name" {}
variable "short_name" {}
variable "ssh_key" {}
variable "ssh_user" {}
variable "zone" {}


# Instances
resource "google_compute_disk" "manlt-worker-lvm" {
  name = "${var.short_name}-worker-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${var.zone}"
  size = "${var.worker_data_volume_size}"

  count = "${var.worker_count}"
}


resource "google_compute_instance" "manlt-worker-nodes" {
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}"
  description = "${var.long_name} worker node #${format("%03d", count.index+1)}"
  machine_type = "${var.worker_type}"
  zone = "${var.zone}"
  can_ip_forward = false
  tags = ["${var.short_name}", "worker"]

  disk {
    image = "${var.image}"
    size = "${var.worker_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.manlt-worker-lvm.*.name, count.index)}"
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
    role = "worker"
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.worker_count}"

  provisioner "remote-exec" {
    script = "./terraform/gce/disk.sh"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
    }
  }
}

output "worker_ips" {
  value = "${join(\",\", google_compute_instance.manlt-worker-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}


