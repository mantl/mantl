variable name {}
variable role {}
variable protocol {}
variable subnet_id {}
variable lb_method {}
variable internal_ips {}
variable lb_port {}
variable upstream_port {}
variable floating_ip { default = "" }
variable count {}

# create lb pool
resource "openstack_lb_pool_v1" "lb_pool" {
  name = "${var.name}-${var.role}-lb-pool"
  protocol = "${var.protocol}"
  subnet_id = "${var.subnet_id}"
  lb_method = "${var.lb_method}"
}

# add members to pool
resource "openstack_lb_member_v1" "lb_member" {
  pool_id = "${openstack_lb_pool_v1.lb_pool.id}"
  address = "${ element(split(",", var.internal_ips), count.index) }"
  port = "${var.upstream_port}"
  count = "${var.count}"
}

# add vip
resource "openstack_lb_vip_v1" "lb_vip" {
  name = "${var.name}-${var.role}-lb-vip"
  subnet_id = "${var.subnet_id}"
  protocol = "${var.protocol}"
  port = "${var.lb_port}"
  pool_id = "${openstack_lb_pool_v1.lb_pool.id}"
  floating_ip = "${var.floating_ip}"
  admin_state_up = true
}
