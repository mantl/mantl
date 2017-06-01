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

resource "google_compute_forwarding_rule" "default" {
  name = "${var.short_name}-www-forwarding-rule"
  target = "${google_compute_target_pool.default.self_link}"
  port_range = "80"
}

resource "google_compute_target_pool" "default" {
  name = "${var.short_name}-www-target-pool"
  instances = ["${split(",", var.instances)}"]
  health_checks = ["${google_compute_http_health_check.default.name}"]
}

output "public_ip" {
  value = "${google_compute_forwarding_rule.default.ip_address}"
}
