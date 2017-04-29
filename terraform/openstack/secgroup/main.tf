variable name { default = "mantl" }

/*==========================================================================

Security group name : common
Description : Contains the rules from default security group + SSH + ICMP
Rules allowed -
  Default security group
  SSH from 0.0.0.0/0
  ICMP from 0.0.0.0/0

-----------------------------------------------------------------------------*/

resource "openstack_networking_secgroup_v2" "secgroup_common" {
  name = "${var.name}-common"
  description = "Common security group for Mantl VMs"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_common_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  remote_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_common_rule_2" {
  direction = "ingress"
  ethertype = "IPv6"
  remote_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_common_rule_3" {
  direction = "egress"
  ethertype = "IPv4"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_common_rule_4" {
  direction = "egress"
  ethertype = "IPv6"
  remote_ip_prefix = "::/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_common_rule_5" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_common_rule_6" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_common.id}"
}

/*==========================================================================

Security group name : web
Description : Contains the rules for edge and proxy nodes
Rules allowed -
  HTTP from 0.0.0.0/0
  HTTPS from 0.0.0.0/0

-----------------------------------------------------------------------------*/

resource "openstack_networking_secgroup_v2" "secgroup_web" {
  name = "${var.name}-web"
  description = "Security group for edge and proxy nodes"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_web_rule_1" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 80
  port_range_max = 80
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_web.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_web_rule_2" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 443
  port_range_max = 443
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_web.id}"
}

output "secgroup_common" {
  value = "${openstack_networking_secgroup_v2.secgroup_common.name}"
}

output "secgroup_web" {
  value = "${openstack_networking_secgroup_v2.secgroup_web.name}"
}
