#monolithic file saved for backward compatibility
variable "control_count" {default = 3}
variable "control_type" {default = "n1-standard-1"}
variable "control_volume_size" {default = "20"} # size is in gigabytes
variable "worker_volume_size" {default = "20"} # size is in gigabytes
variable "control_data_volume_size" {default = "20"} # size is in gigabytes
variable "worker_data_volume_size" {default = "100"} # size is in gigabytes
variable "datacenter" {default = "gce"}
variable "edge_type" {default = "n1-standard-1"}
variable "edge_count" {default = 2}
variable "edge_volume_size" {default = "10"} # size is in gigabytes
variable "edge_data_volume_size" {default = "20"} # size is in gigabytes
variable "long_name" {default = "microservices-infastructure"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "region" {default = "us-central1"}
variable "short_name" {default = "mi"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_user" {default = "centos"}
variable "kubeworker_count" {default = 0}
variable "worker_count" {default = 1}
variable "worker_type" {default = "n1-highcpu-2"}
variable "zone" {default = "us-central1-a"}

# Network
resource "google_compute_network" "mi-network" {
  name = "${var.long_name}"
  ipv4_range = "${var.network_ipv4}"
}

# Firewall
resource "google_compute_firewall" "mi-firewall-external" {
  name = "${var.short_name}-firewall-external"
  network = "${google_compute_network.mi-network.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "22",   # SSH
      "80",   # HTTP
      "443",  # HTTPS
      "4400", # Chronos
      "5050", # Mesos
      "8080", # Marathon
      "8500"  # Consul API
    ]
  }
}

resource "google_compute_firewall" "mi-firewall-internal" {
  name = "${var.short_name}-firewall-internal"
  network = "${google_compute_network.mi-network.name}"
  source_ranges = ["${google_compute_network.mi-network.ipv4_range}"]

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }
}

# Instances
resource "google_compute_disk" "mi-control-lvm" {
  name = "${var.short_name}-control-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${var.zone}"
  size = "${var.control_data_volume_size}"

  count = "${var.control_count}"
}

resource "google_compute_disk" "mi-worker-lvm" {
  name = "${var.short_name}-worker-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${var.zone}"
  size = "${var.worker_data_volume_size}"

  count = "${var.worker_count}"
}

resource "google_compute_disk" "mi-kubeworker-lvm" {
  name = "${var.short_name}-kubeworker-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${var.zone}"
  size = "${var.worker_data_volume_size}"

  count = "${var.kubeworker_count}"
}

resource "google_compute_disk" "mi-edge-lvm" {
  name = "${var.short_name}-edge-lvm-${format("%02d", count.index+1)}"
  type = "pd-ssd"
  zone = "${var.zone}"
  size = "${var.edge_data_volume_size}"

  count = "${var.edge_count}"
}

resource "google_compute_instance" "mi-control-nodes" {
  name = "${var.short_name}-control-${format("%02d", count.index+1)}"
  description = "${var.long_name} control node #${format("%02d", count.index+1)}"
  machine_type = "${var.control_type}"
  zone = "${var.zone}"
  can_ip_forward = false
  tags = ["${var.short_name}", "control"]

  disk {
    image = "centos-7-v20160119"
    size = "${var.control_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.mi-control-lvm.*.name, count.index)}"
    auto_delete = false

    # make disk available as "/dev/disk/by-id/google-lvm"
    # NOTE: "google-" prefix is auto added
    device_name = "lvm"
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
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

resource "google_compute_instance" "mi-worker-nodes" {
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}"
  description = "${var.long_name} worker node #${format("%03d", count.index+1)}"
  machine_type = "${var.worker_type}"
  zone = "${var.zone}"
  can_ip_forward = false
  tags = ["${var.short_name}", "worker"]

  disk {
    image = "centos-7-v20160119"
    size = "${var.worker_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.mi-worker-lvm.*.name, count.index)}"
    auto_delete = false

    # make disk available as "/dev/disk/by-id/google-lvm"
    # NOTE: "google-" prefix is auto added
    device_name = "lvm"
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
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

resource "google_compute_instance" "mi-kubeworker-nodes" {
  name = "${var.short_name}-kubeworker-${format("%03d", count.index+1)}"
  description = "${var.long_name} kube worker node #${format("%03d", count.index+1)}"
  machine_type = "${var.worker_type}"
  zone = "${var.zone}"
  can_ip_forward = false
  tags = ["${var.short_name}", "kubeworker"]

  disk {
    image = "centos-7-v20150526"
    size = "${var.worker_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.mi-kubeworker-lvm.*.name, count.index)}"
    auto_delete = false

    # make disk available as "/dev/disk/by-id/google-lvm"
    # NOTE: "google-" prefix is auto added
    device_name = "lvm"
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
    access_config {}
  }

  metadata {
    dc = "${var.datacenter}"
    role = "kubeworker"
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
    ssh_user = "${var.ssh_user}"
  }

  count = "${var.kubeworker_count}"

  provisioner "remote-exec" {
    script = "./terraform/gce/disk.sh"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
    }
  }
}

resource "google_compute_instance" "mi-edge-nodes" {
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}"
  description = "${var.long_name} edge node #${format("%02d", count.index+1)}"
  machine_type = "${var.edge_type}"
  zone = "${var.zone}"
  can_ip_forward = false
  tags = ["${var.short_name}", "edge"]

  disk {
    image = "centos-7-v20160119"
    size = "${var.edge_volume_size}"
    auto_delete = true
  }

  disk {
    disk = "${element(google_compute_disk.mi-edge-lvm.*.name, count.index)}"
    auto_delete = false

    # make disk available as "/dev/disk/by-id/google-lvm"
    # NOTE: "google-" prefix is auto added
    device_name = "lvm"
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
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

output "control_ips" {
  value = "${join(\",\", google_compute_instance.mi-control-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}

output "worker_ips" {
  value = "${join(\",\", google_compute_instance.mi-worker-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}

output "kubeworker_ips" {
  value = "${join(\",\", google_compute_instance.mi-kubeworker-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}

output "edge_ips" {
  value = "${join(\",\", google_compute_instance.mi-edge-nodes.*.network_interface.0.access_config.0.nat_ip)}"
}
