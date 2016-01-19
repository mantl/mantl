# input variables
variable control_count {}
variable control_ips {}
variable control_subdomain { default = "control" }
variable domain {}
variable edge_count {}
variable edge_ips {}
variable hosted_zone_id {}
variable short_name {}
variable subdomain { default = "" }
variable worker_count {}
variable worker_ips {}

# individual records
resource "aws_route53_record" "dns-control" {
  count = "${var.control_count}"
  zone_id = "${var.hosted_zone_id}"
  records = ["${element(split(",", var.control_ips), count.index)}"]
  name = "${var.short_name}-control-${format("%02d", count.index+1)}.node.${var.domain}"
  type = "A"
  ttl = 60
}

resource "aws_route53_record" "dns-edge" {
  count = "${var.edge_count}"
  zone_id = "${var.hosted_zone_id}"
  records = ["${element(split(",", var.edge_ips), count.index)}"]
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}.node.${var.domain}"
  type = "A"
  ttl = 60
}

resource "aws_route53_record" "dns-worker" {
  count = "${var.worker_count}"
  zone_id = "${var.hosted_zone_id}"
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}.node.${var.domain}"
  records = ["${element(split(",", var.worker_ips), count.index)}"]
  type = "A"
  ttl = 60
}

# group records
resource "aws_route53_record" "dns-control-group" {
  count = "${var.control_count}"
  zone_id = "${var.hosted_zone_id}"
  name = "${var.control_subdomain}${var.subdomain}.${var.domain}"
  records = ["${split(",", var.control_ips)}"]
  type = "A"
  ttl = 60
}

resource "aws_route53_record" "dns-wildcard" {
  count = "${var.edge_count}"
  zone_id = "${var.hosted_zone_id}"
  name = "*${var.subdomain}.${var.domain}"
  records = ["${split(",", var.edge_ips)}"]
  type = "A"
  ttl = 60
}
