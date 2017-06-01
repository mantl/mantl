variable keypair_name {}
variable public_key {}

resource "openstack_compute_keypair_v2" "keypair" {
  name = "${var.keypair_name}"
  public_key = "${file(var.public_key)}"
}

output "keypair_name" {
  value = "${openstack_compute_keypair_v2.keypair.name}"
}

output "name" {
  value = "${openstack_compute_keypair_v2.keypair.name}"
}
