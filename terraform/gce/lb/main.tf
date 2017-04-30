variable "short_name" {}
variable "instances" {}

resource "google_compute_http_health_check" "default" {
  name = "${var.short_name}-www-basic-check"
  request_path = "/"
  check_interval_sec = 1
  healthy_threshold = 1
  unhealthy_threshold = 10
  timeout_sec = 1
}

resource "google_compute_address" "edge-lb" {
  name = "lb"
}

resource "google_compute_forwarding_rule" "http" {
  name = "${var.short_name}-http-forwarding-rule"
  target = "${google_compute_target_pool.default.self_link}"
  ip_address = "${google_compute_address.edge-lb.address}"
  port_range = "80"
}

resource "google_compute_forwarding_rule" "https" {
  name = "${var.short_name}-https-forwarding-rule"
  target = "${google_compute_target_pool.default.self_link}"
  ip_address = "${google_compute_address.edge-lb.address}"
  port_range = "443"
}

resource "google_compute_target_pool" "default" {
  name = "${var.short_name}-www-target-pool"
  instances = ["${split(",", var.instances)}"]
  health_checks = ["${google_compute_http_health_check.default.name}"]
}

output "public_ip" {
  value = "${google_compute_address.edge-lb.address}"
}
