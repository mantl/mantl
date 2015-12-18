variable "worker_count" {default = "1"}
variable "worker_iam_profile" {default = "" }
variable "worker_type" {default = "m3.medium"}
variable "worker_volume_size" {default = "20"} # size is in gigabytes
variable "worker_data_volume_size" {default = "100"} # size is in gigabytes

variable "short_name" {default = "mantl"}
variable "availability_zone" {}
variable "ssh_key_pair" {}
variable "datacenter" {}
variable "source_ami" {}
variable "aws_vpc_id" {}
variable "aws_default_security_group_id" {}
variable "aws_vpc_subnet_id" {}
variable "ssh_username" {default = "centos"}

resource "aws_ebs_volume" "mi-worker-lvm" {
  availability_zone = "${var.availability_zone}"
  count = "${var.worker_count}"
  size = "${var.worker_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-worker-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "mi-worker-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.worker_type}"
  count = "${var.worker_count}"
  vpc_security_group_ids = ["${aws_security_group.worker.id}",
    "${var.aws_default_security_group_id}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${var.aws_vpc_subnet_id}"
  iam_instance_profile = "${var.worker_iam_profile}"
  root_block_device {
    delete_on_termination = true
    volume_size = "${var.worker_volume_size}"
  }
  tags {
    Name = "${var.short_name}-worker-${format("%03d", count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "worker"
    dc = "${var.datacenter}"
  }
}

resource "aws_volume_attachment" "mi-worker-nodes-lvm-attachment" {
  count = "${var.worker_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.mi-worker-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.mi-worker-lvm.*.id, count.index)}"
  force_detach = true
}

resource "aws_security_group" "worker" {
  name = "${var.short_name}-worker"
  description = "Allow inbound traffic for worker nodes"
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

output "worker_security_group" {
  value = "${aws_security_group.worker.id}"
}

output "worker_ips" {
  value = "${join(\",\", aws_instance.mi-worker-nodes.*.public_ip)}"
}