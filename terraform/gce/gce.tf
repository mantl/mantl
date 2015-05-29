variable "control_count" {default = 3}
variable "control_type" {default = "n1-standard-1"}
variable "datacenter" {default = "gce"}
variable "long_name" {default = "microservices-infastructure"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "region" {default = "us-central1-a"}
variable "short_name" {default = "mi"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_username" {default = "deploy"}
variable "worker_count" {default = 1}
variable "worker_type" {default = "n1-highcpu-2"}

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

  # RDP
  allow {
    protocol = "tcp"
    ports = [
      "22",   # SSH
      "3389", # RDP
      "5050", # Mesos
      "8080", # Marathon
      "8500"  # Consul UI
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
resource "google_compute_instance" "mi-control-nodes" {
  name = "${var.short_name}-control-${format("%02d", count.index+1)}"
  description = "${var.long_name} control node #${format("%02d", count.index+1)}"
  machine_type = "${var.control_type}"
  zone = "${var.region}"
  can_ip_forward = false
  tags = ["${var.short_name}", "control"]

  disk {
    image = "centos-7-v20150526"
    auto_delete = true
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
    access_config {}
  }

  metadata {
    sshKeys = "${var.ssh_username}:${file(var.ssh_key)} ${var.ssh_username}"
    role = "control"
    dc = "${var.datacenter}"
  }

  count = "${var.control_count}"
}

resource "google_compute_instance" "mi-worker-nodes" {
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}"
  description = "${var.long_name} worker node #${format("%03d", count.index+1)}"
  machine_type = "${var.worker_type}"
  zone = "${var.region}"
  can_ip_forward = false
  tags = ["${var.short_name}", "worker"]

  disk {
    image = "centos-7-v20150526"
    auto_delete = true
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
    access_config {}
  }

  metadata {
    sshKeys = "${var.ssh_username}:${file(var.ssh_key)} ${var.ssh_username}"
    role = "worker"
    dc = "${var.datacenter}"
  }

  count = "${var.worker_count}"
}
