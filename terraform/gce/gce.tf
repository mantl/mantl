variable "project" {
  default = "asteris-mi"
}
variable "names" {
  default = {
    long = "microservices-infastructure"
    short = "mi"
  }
}
variable "region" {
  default = "us-central1"
}
variable "instance_types" {
  default = {
    control = "n1-standard-1"
    worker = "n1-highcpu-2"
  }
}
variable "network_ipv4" { default = "10.0.0.0/16" }
variable "ssh" {
  default = {
    username = "deploy"
    key = "~/.ssh/id_rsa.pub"
  }
}

# Configure the Google Cloud provider
provider "google" {
  account_file = "account.json"
  project = "${var.project}"
  region = "${var.region}"
}

# Network
resource "google_compute_network" "mi-network" {
  name = "${var.names.long}"
  ipv4_range = "${var.network_ipv4}"
}

# Firewall
resource "google_compute_firewall" "mi-firewall-external" {
  name = "${var.names.short}-firewall-external"
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
      "8080"  # Marathon
    ]
  }
}

resource "google_compute_firewall" "mi-firewall-internal" {
  name = "${var.names.short}-firewall-internal"
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
  name = "${var.names.short}-control-node-${format("%02d", count.index+1)}"
  description = "${var.names.long} control node #${format("%02d", count.index+1)}"
  machine_type = "${var.instance_types.control}"
  zone = "${var.region}-a"
  can_ip_forward = false
  tags = ["${var.names.short}", "control"]

  disk {
    image = "centos-7-v20150423"
    auto_delete = true
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
    access_config {}
  }

  metadata {
    sshKeys = "${var.ssh.username}:${file(var.ssh.key)} ${var.ssh.username}"
    role = "control"
  }

  count = 1
}

resource "google_compute_instance" "mi-worker-nodes" {
  name = "${var.names.short}-worker-node-${format("%03d", count.index+1)}"
  description = "${var.names.long} worker node #${format("%03d", count.index+1)}"
  machine_type = "${var.instance_types.worker}"
  zone = "${var.region}-a"
  can_ip_forward = false
  tags = ["${var.names.short}", "worker"]

  disk {
    image = "centos-7-v20150423"
    auto_delete = true
  }

  network_interface {
    network = "${google_compute_network.mi-network.name}"
    access_config {}
  }

  metadata {
    sshKeys = "${var.ssh.username}:${file(var.ssh.key)} ${var.ssh.username}"
    role = "worker"
  }

  count = 3
}
