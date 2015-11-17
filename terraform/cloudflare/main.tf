# input variables
variable control_count {}
variable control_ips {}
variable domain {}
variable edge_count {}
variable edge_ips {}
variable short_name {}
variable subdomain { default = "" }

# records
resource "cloudflare_record" "dns-control" {
  count = "${var.control_count}"
  domain = "${var.domain}"
  value = "${element(split(\",\", var.control_ips), count.index)}"
  name = "control${var.subdomain}"
  type = "A"
  ttl = 1 # automatic
}

resource "cloudflare_record" "dns-edge" {
  count = "${var.edge_count}"
  domain = "${var.domain}"
  value = "${element(split(\",\", var.edge_ips), count.index)}"
  name = "*${var.subdomain}"
  type = "A"
  ttl = 1 # automatic
}
