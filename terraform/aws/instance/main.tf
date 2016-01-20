variable "count" {default = "4"}
variable "iam_profile" {default = "" }
variable "ec2_type" {default = "m3.medium"}
variable "ebs_volume_size" {default = "20"} # size is in gigabytes
variable "data_ebs_volume_size" {default = "20"} # size is in gigabytes
variable "role" {}
variable "short_name" {default = "mantl"}
variable "availability_zones" {}
variable "ssh_key_pair" {}
variable "datacenter" {}
variable "source_ami" {}
variable "vpc_id" {}
variable "default_security_group_id" {}
variable "vpc_subnet_ids" {}
variable "ssh_username" {default = "centos"}


resource "aws_ebs_volume" "ebs" {
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count = "${var.count}"
  size = "${var.data_ebs_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-${var.role}-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "instance" {
  ami = "${var.source_ami}"
  instance_type = "${var.ec2_type}"
  count = "${var.count}"
  vpc_security_group_ids = ["${aws_security_group.main.id}",
    "${aws_security_group.ui.id}",
    "${var.default_security_group_id}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${element(split(",", var.vpc_subnet_ids), count.index)}" 
  iam_instance_profile = "${var.iam_profile}"
  root_block_device {
    delete_on_termination = true
    volume_size = "${var.ebs_volume_size}"
  }

  tags {
    Name = "${var.short_name}-${var.role}-${format("%02d", count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "${var.role}"
    dc = "${var.datacenter}"
  }
}

resource "aws_volume_attachment" "instance-lvm-attachment" {
  count = "${var.count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.ebs.*.id, count.index)}"
  force_detach = true
}

resource "aws_security_group" "main" {
  name = "${var.short_name}-${var.role}"
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

output "main_security_group" {
  value = "${aws_security_group.main.id}"
}

output "ui_security_group" {
  value = "${aws_security_group.ui.id}"
}


output "ec2_ids" {
  value = "${join(\",\", aws_instance.instance.*.id)}"
}

output "ec2_ips" {
  value = "${join(\",\", aws_instance.instance.*.public_ip)}"
}