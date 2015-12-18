variable "control_count" {default = "3"}
variable "control_iam_profile" {default = "" }
variable "control_type" {default = "m3.medium"}
variable "control_volume_size" {default = "20"} # size is in gigabytes
variable "control_data_volume_size" {default = "20"} # size is in gigabytes

variable "short_name" {default = "mantl"}
variable "availability_zone" {}
variable "ssh_key_pair" {}
variable "datacenter" {}
variable "source_ami" {}
variable "vpc_id" {}
variable "default_security_group_id" {}
variable "vpc_subnet_id" {}
variable "ssh_username" {default = "centos"}


resource "aws_ebs_volume" "mantl-control-lvm" {
  availability_zone = "${var.availability_zone}"
  count = "${var.control_count}"
  size = "${var.control_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-control-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "mantl-control-nodes" {
  ami = "${var.source_ami}"
  #availability_zone = "${var.availability_zone}"
  instance_type = "${var.control_type}"
  count = "${var.control_count}"
  vpc_security_group_ids = ["${aws_security_group.control.id}",
    "${aws_security_group.ui.id}",
    "${var.default_security_group_id}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${var.vpc_subnet_id}"
  iam_instance_profile = "${var.control_iam_profile}"
  root_block_device {
    delete_on_termination = true
    volume_size = "${var.control_volume_size}"
  }

  tags {
    Name = "${var.short_name}-control-${format("%02d", count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "control"
    dc = "${var.datacenter}"
  }
}

resource "aws_volume_attachment" "mantl-control-nodes-lvm-attachment" {
  count = "${var.control_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.mantl-control-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.mantl-control-lvm.*.id, count.index)}"
  force_detach = true
}

resource "aws_security_group" "control" {
  name = "${var.short_name}-control"
  description = "Allow inbound traffic for control nodes"
  vpc_id = "${var.vpc_id}"

  ingress { # SSH
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Mesos
    from_port = 5050
    to_port = 5050
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Marathon
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Chronos
    from_port = 4400
    to_port = 4400
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # Consul
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # ICMP
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "ui" {
  name = "${var.short_name}-ui"
  description = "Allow inbound traffic for Mantl UI"
  vpc_id = "${var.vpc_id}"

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

  ingress { # Consul
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "control_security_group" {
  value = "${aws_security_group.control.id}"
}

output "ui_security_group" {
  value = "${aws_security_group.ui.id}"
}


output "control_ids" {
  value = "${join(\",\", aws_instance.mantl-control-nodes.*.id)}"
}

output "control_ips" {
  value = "${join(\",\", aws_instance.mantl-control-nodes.*.public_ip)}"
}