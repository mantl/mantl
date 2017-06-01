# WARNING: This module has been deprecated as of Mantl 1.0

variable auth_url {}
variable tenant_id {}
variable tenant_name {}
variable keypair_name {}
variable public_key {}

provider "openstack" {
  auth_url = "${ var.auth_url }"
  tenant_id = "${ var.tenant_id }"
  tenant_name = "${ var.tenant_name }"
}

resource "openstack_compute_keypair_v2" "keypair" {
  name = "${ var.keypair_name }"
  public_key = "${ file(var.public_key) }"
}

output "keypair_name" {
 value = "${ openstack_compute_keypair_v2.keypair.name }"
}
