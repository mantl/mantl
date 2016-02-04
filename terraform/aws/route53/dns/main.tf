# input variables
variable control_count {}
variable control_ips {}
variable control_subdomain { default = "control" }
variable domain {}
variable edge_count {}
variable edge_ips {}
variable elb_fqdn {}
variable hosted_zone_id {}
variable short_name {}
variable subdomain { default = "" }
variable traefik_elb_fqdn {}
variable traefik_zone_id {}
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
  zone_id = "${var.hosted_zone_id}"
  name = "*${var.subdomain}.${var.domain}"
  type = "A"

  alias {
    zone_id = "${var.traefik_zone_id}"
    name = "${var.traefik_elb_fqdn}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "elb-cname" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.short_name}"  
  type = "CNAME"
  ttl = 5
  records = ["${var.elb_fqdn}"]
}

output "elb_cname" {
  value = "${aws_route53_record.elb-cname.fqdn}"
}

output "edge_fqdn" {
  value = "${join(\",\", aws_route53_record.dns-edge.*.fqdn)}"
}

output "control_fqdn" {
  value = "${join(\",\", aws_route53_record.dns-control.*.fqdn)}"
}

output "worker_fqdn" {
  value = "${join(\",\", aws_route53_record.dns-worker.*.fqdn)}"
}