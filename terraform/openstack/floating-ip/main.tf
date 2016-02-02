variable floating_pool {} 
variable count { default = "1" }

resource "openstack_compute_floatingip_v2" "floating-ip" {
  pool = "${var.floating_pool}"
  count = "${var.count}"
}

output "ip_list" {
  value = "${join(",", openstack_compute_floatingip_v2.floating-ip.*.address)}"
}
