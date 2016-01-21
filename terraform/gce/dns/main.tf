# input variables
variable control_count {}
variable control_ips {}
variable control_subdomain { default = "control" }
variable domain {}
variable edge_count {}
variable edge_ips {}
variable lb_ip {}
variable managed_zone {}
variable short_name {}
variable subdomain { default = "" }
variable worker_count {}
variable worker_ips {}

# individual records
resource "google_dns_record_set" "dns-control" {
  count = "${var.control_count}"
  managed_zone = "${var.managed_zone}"
  name = "${var.short_name}-control-${format("%02d", count.index+1)}.node${var.subdomain}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${element(split(",", var.control_ips), count.index)}"]
}

resource "google_dns_record_set" "dns-edge" {
  count = "${var.edge_count}"
  managed_zone = "${var.managed_zone}"
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}.node${var.subdomain}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${element(split(",", var.edge_ips), count.index)}"]
}

resource "google_dns_record_set" "dns-worker" {
  count = "${var.worker_count}"
  managed_zone = "${var.managed_zone}"
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}.node${var.subdomain}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${element(split(",", var.worker_ips), count.index)}"]
}

# group records
resource "google_dns_record_set" "dns-control-group" {
  managed_zone = "${var.managed_zone}"
  name = "${var.control_subdomain}${var.subdomain}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${split(",", var.control_ips)}"]
}

resource "google_dns_record_set" "dns-wildcard" {
  managed_zone = "${var.managed_zone}"
  name = "*${var.subdomain}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${var.lb_ip}"]
}
