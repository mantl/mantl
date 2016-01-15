variable "edge_count" {default = 2}
variable "edge_iam_profile" {default = ""}
variable "edge_type" {default = "m3.medium"}
variable "edge_volume_size" {default = "10"} # size is in gigabytes
variable "edge_data_volume_size" {default = "20"} # size is in gigabytes

variable "short_name" {default = "mantl"}
variable "availability_zones" {}
variable "ssh_key_pair" {}
variable "datacenter" {}
variable "source_ami" {}
variable "vpc_id" {}
variable "default_security_group_id" {}
variable "vpc_subnet_ids" {}
variable "ssh_username" {default = "centos"}


resource "aws_ebs_volume" "mantl-edge-lvm" {
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count = "${var.edge_count}"
  size = "${var.edge_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-edge-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "mantl-edge-nodes" {
  ami = "${var.source_ami}"
  instance_type = "${var.edge_type}"
  count = "${var.edge_count}"
  vpc_security_group_ids = ["${aws_security_group.edge.id}",
    "${var.default_security_group_id}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${element(split(",", var.vpc_subnet_ids), count.index)}" 
  iam_instance_profile = "${var.edge_iam_profile}"
  root_block_device {
    delete_on_termination = true
    volume_size = "${var.edge_volume_size}"
  }
  tags {
    Name = "${var.short_name}-edge-${format("%02d", count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "edge"
    dc = "${var.datacenter}"
  }
}

resource "aws_volume_attachment" "mantl-edge-nodes-lvm-attachment" {
  count = "${var.edge_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.mantl-edge-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.mantl-edge-lvm.*.id, count.index)}"
  force_detach = true
}

resource "aws_security_group" "edge" {
  name = "${var.short_name}-edge"
  description = "Allow inbound traffic for edge routing"
  vpc_id = "${var.vpc_id}"

  ingress { # SSH
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTP
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTPS
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "control_security_group" {
  value = "${aws_security_group.edge.id}"
}

output "edge_ids" {
  value = "${join(\",\", aws_instance.mantl-edge-nodes.*.id)}"
}


output "edge_ips" {
  value = "${join(\",\", aws_instance.mantl-edge-nodes.*.public_ip)}"
}