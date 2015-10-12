variable control_ips {}
variable worker_ips {}
variable control_count {}
variable worker_count {}
variable domain {}
variable short_name {}
variable managed_zone {}

resource "google_dns_record_set" "dns-control" {
  count = "${var.control_count}"
  managed_zone = "${var.managed_zone}"
  name = "${var.short_name}-control-${format("%02d", count.index+1)}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${element(split(\",\", var.control_ips), count.index)}"]
}

resource "google_dns_record_set" "dns-worker" {
  count = "${var.worker_count}"
  managed_zone = "${var.managed_zone}"
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${element(split(\",\", var.worker_ips), count.index)}"]
}

resource "google_dns_record_set" "dns-worker-haproxy" {
  managed_zone = "${var.managed_zone}"
  name = "${var.short_name}-lb.${var.domain}."
  type = "A"
  ttl = 60
  rrdatas = ["${split(\",\", var.worker_ips)}"]
}
