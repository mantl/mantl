variable ssl_cert_file { default = "./ssl/certs/nginx.cert.pem" }
variable ssl_key_file { default = "./ssl/private/nginx.key.pem" }
variable short_name { }
variable instances {}
variable subnets {}
variable security_groups {}

resource "aws_iam_server_certificate" "elb_cert" {
  name = "${var.short_name}-traefik-elb-certificate"
  certificate_body = "${file(var.ssl_cert_file)}"
  private_key = "${file(var.ssl_key_file)}"
}

resource "aws_elb" "traefik-elb" {
  name = "${var.short_name}-traefik-elb"
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  subnets = ["${split(\",\", var.subnets)}"]
  security_groups = ["${split(\",\", var.security_groups)}"]
  instances = ["${split(\",\", var.instances)}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 443
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.elb_cert.arn}"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:80"
    interval = 30
  }

  tags {
    Name = "${var.short_name}-elb"
  }
}

output "fqdn" {
  value = "${aws_elb.traefik-elb.dns_name}"
}

output "zone_id" {
  value = "${aws_elb.traefik-elb.zone_id}"
}
