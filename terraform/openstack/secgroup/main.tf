variable secgroup_name { default = "mantl-secgroup" }

resource "openstack_compute_secgroup_v2" "secgroup" {
  name = "${var.secgroup_name}"
  description = "Security Group ${var.secgroup_name}"
  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    self        = true
  }
  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "udp"
    self        = true
  }
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    self        = true
  }
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

output "secgroup_name" {
  value = "${openstack_compute_secgroup_v2.secgroup.name}"
  }