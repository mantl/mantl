variable control_ips {}
variable worker_ips {}
variable control_count {}
variable worker_count {}
variable domain {}
variable short_name {}
variable hosted_zone_id {}

resource "aws_route53_record" "dns-control" {
  count = "${var.control_count}"
  zone_id = "${var.hosted_zone_id}"
  records = ["${element(split(\",\", var.control_ips), count.index)}"]
  name = "${var.short_name}-control-${format("%02d", count.index+1)}.${var.domain}"
  type = "A"
  ttl = 60
}

resource "aws_route53_record" "dns-worker" {
  count = "${var.worker_count}"
  zone_id = "${var.hosted_zone_id}"
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}.${var.domain}"
  records = ["${element(split(\",\", var.worker_ips), count.index)}"]
  type = "A"
  ttl = 60
}

resource "aws_route53_record" "dns-worker-haproxy" {
  count = "${var.worker_count}"
  zone_id = "${var.hosted_zone_id}"
  name = "*.${var.short_name}-lb.${var.domain}"
  records = ["${element(split(\",\", var.worker_ips), count.index)}"]
  type = "A"
  ttl = 60
}
