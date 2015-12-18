variable "edge_count" {default = 2}
variable "edge_iam_profile" {default = ""}
variable "edge_type" {default = "m3.medium"}
variable "edge_volume_size" {default = "10"} # size is in gigabytes
variable "edge_data_volume_size" {default = "20"} # size is in gigabytes

variable "short_name" {default = "mantl"}
variable "availability_zone" {}
variable "ssh_key_pair" {}
variable "datacenter" {}
variable "source_ami" {}
variable "aws_vpc_id" {}
variable "aws_default_security_group_id" {}
variable "aws_vpc_subnet_id" {}
variable "ssh_username" {default = "centos"}


resource "aws_ebs_volume" "mi-edge-lvm" {
  availability_zone = "${var.availability_zone}"
  count = "${var.edge_count}"
  size = "${var.edge_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-edge-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "mi-edge-nodes" {
  ami = "${var.source_ami}"
  #availability_zone = "${var.availability_zone}"
  instance_type = "${var.edge_type}"
  count = "${var.edge_count}"
  vpc_security_group_ids = ["${aws_security_group.edge.id}",
    "${var.aws_default_security_group_id}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${var.aws_vpc_subnet_id}"
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

resource "aws_volume_attachment" "mi-edge-nodes-lvm-attachment" {
  count = "${var.edge_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.mi-edge-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.mi-edge-lvm.*.id, count.index)}"
  force_detach = true
}

resource "aws_security_group" "edge" {
  name = "${var.short_name}-edge"
  description = "Allow inbound traffic for edge routing"
  vpc_id = "${var.aws_vpc_id}"

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

output "edge_ips" {
  value = "${join(\",\", aws_instance.mi-edge-nodes.*.public_ip)}"
}