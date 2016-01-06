variable "long_name" {default = "mantl"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "short_name" {default = "mi"}

# Network
resource "google_compute_network" "mantl-network" {
  name = "${var.long_name}"
  ipv4_range = "${var.network_ipv4}"
}

# Firewall
resource "google_compute_firewall" "mantl-firewall-external" {
  name = "${var.short_name}-firewall-external"
  network = "${google_compute_network.mantl-network.name}"
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

resource "google_compute_firewall" "mantl-firewall-internal" {
  name = "${var.short_name}-firewall-internal"
  network = "${google_compute_network.mantl-network.name}"
  source_ranges = ["${google_compute_network.mantl-network.ipv4_range}"]

  allow {
    protocol = "tcp"
    ports = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["1-65535"]
  }
}


output "network_name" {
  value = "${google_compute_network.mantl-network.name}"
}

output "ip_range" {
  value = "${google_compute_network.mantl-network.ipv4_range}"
}


