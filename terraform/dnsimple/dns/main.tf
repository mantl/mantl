# input variables
variable control_count {}
variable control_ips {}
variable control_subdomain { default = "control" }
variable domain {}
variable edge_count {}
variable edge_ips {}
variable short_name {}
variable subdomain { default = "" }
variable worker_count {}
variable worker_ips {}
variable kubeworker_count { default = "0" }
variable kubeworker_ips { default = "" }

# individual records
resource "dnsimple_record" "dns-control" {
  count = "${var.control_count}"
  domain = "${var.domain}"
  value = "${element(split(",", var.control_ips), count.index)}"
  name = "${var.short_name}-control-${format("%02d", count.index+1)}.node${var.subdomain}"
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "dns-edge" {
  count = "${var.edge_count}"
  domain = "${var.domain}"
  value = "${element(split(",", var.edge_ips), count.index)}"
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}.node${var.subdomain}"
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "dns-worker" {
  count = "${var.worker_count}"
  domain = "${var.domain}"
  value = "${element(split(",", var.worker_ips), count.index)}"
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}.node${var.subdomain}"
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "dns-kubeworker" {
  count = "${var.kubeworker_count}"
  domain = "${var.domain}"
  value = "${element(split(",", var.kubeworker_ips), count.index)}"
  name = "${var.short_name}-kubeworker-${format("%03d", count.index+1)}.node${var.subdomain}"
  type = "A"
  ttl = 60
}

# group records
resource "dnsimple_record" "dns-control-group" {
  count = "${var.control_count}"
  domain = "${var.domain}"
  value = "${element(split(",", var.control_ips), count.index)}"
  name = "${var.control_subdomain}${var.subdomain}"
  type = "A"
  ttl = 60
}

resource "dnsimple_record" "dns-wildcard" {
  count = "${var.edge_count}"
  domain = "${var.domain}"
  value = "${element(split(",", var.edge_ips), count.index)}"
  name = "*${var.subdomain}"
  type = "A"
  ttl = 60
}
