# Example showing how to create a load balancer for the control nodes,
# and one for the edge nodes. This also assigns a FIP to each LB.
# Copy this file to the root project to enable.

# create floating ip for use with control load balancer
resource "openstack_networking_floatingip_v2" "control-lb-floating-ip" {
  pool = "${var.floating_ip_pool}"
}

# create neutron lb (via lbaas) for control nodes
module "control-lb" {
  source = "./terraform/openstack/lbaas"
  name = "${var.name}"
  role = "control"
  protocol = "HTTPS"
  subnet_id = "${module.network.subnet_uuid}"
  lb_method = "ROUND_ROBIN"
  internal_ips = "${module.instances-control.ip_v4_list}"
  lb_port = 443
  upstream_port = 443
  floating_ip = "${openstack_networking_floatingip_v2.control-lb-floating-ip.address}"
  count = "${var.control_count}"
}

# create floating ip for use with edge load balancer
resource "openstack_networking_floatingip_v2" "edge-lb-floating-ip" {
  pool = "${var.floating_ip_pool}"
}

# create neutron lb (via lbaas) for edge nodes
module "edge-lb" {
  source = "./terraform/openstack/lbaas"
  name = "${var.name}"
  role = "edge"
  protocol = "HTTP"
  subnet_id = "${module.network.subnet_uuid}"
  lb_method = "ROUND_ROBIN"
  internal_ips = "${module.instances-edge.ip_v4_list}"
  lb_port = 80
  upstream_port = 80
  floating_ip = "${openstack_networking_floatingip_v2.edge-lb-floating-ip.address}"
  count = "${var.edge_count}"
}
