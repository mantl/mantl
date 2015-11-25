variable "availability_zone" {}
variable "control_count" {default = "3"}
variable "control_iam_profile" {default = "" }
variable "control_type" {default = "m3.medium"}
variable "control_volume_size" {default = "20"} # size is in gigabytes
variable "control_data_volume_size" {default = "20"} # size is in gigabytes
variable "worker_data_volume_size" {default = "100"} # size is in gigabytes
variable "datacenter" {default = "aws"}
variable "edge_count" {default = 2}
variable "edge_iam_profile" {default = ""}
variable "edge_type" {default = "m3.medium"}
variable "edge_volume_size" {default = "10"} # size is in gigabytes
variable "edge_data_volume_size" {default = "20"} # size is in gigabytes
variable "long_name" {default = "microservices-infastructure"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "network_subnet_ip4" {default = "10.0.0.0/16"}
variable "short_name" {default = "mi"}
variable "source_ami" {}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_username"  {default = "centos"}
variable "worker_count" {default = "1"}
variable "worker_iam_profile" {default = "" }
variable "worker_type" {default = "m3.medium"}
variable "worker_volume_size" {default = "20"} # size is in gigabytes

resource "aws_vpc" "main" {
  cidr_block = "${var.network_ipv4}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.network_subnet_ip4}"
  availability_zone = "${var.availability_zone}"
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_ebs_volume" "mi-control-lvm" {
  availability_zone = "${var.availability_zone}"
  count = "${var.control_count}"
  size = "${var.control_data_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-control-lvm-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "mi-control-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.control_type}"
  count = "${var.control_count}"
  vpc_security_group_ids = ["${aws_security_group.control.id}",
    "${aws_security_group.ui.id}",
    "${aws_vpc.main.default_security_group_id}"]

  key_name = "${aws_key_pair.deployer.key_name}"

  associate_public_ip_address = true

  subnet_id = "${aws_subnet.main.id}"

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

resource "aws_volume_attachment" "mi-control-nodes-lvm-attachment" {
  count = "${var.control_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.mi-control-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.mi-control-lvm.*.id, count.index)}"
  force_detach = true
}

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
    "${aws_vpc.main.default_security_group_id}"]


  key_name = "${aws_key_pair.deployer.key_name}"

  associate_public_ip_address = true

  subnet_id = "${aws_subnet.main.id}"

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
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.edge_type}"
  count = "${var.edge_count}"

  vpc_security_group_ids = ["${aws_security_group.edge.id}",
    "${aws_vpc.main.default_security_group_id}"]

  key_name = "${aws_key_pair.deployer.key_name}"

  associate_public_ip_address = true

  subnet_id = "${aws_subnet.main.id}"

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

resource "aws_security_group" "control" {
  name = "${var.short_name}-control"
  description = "Allow inbound traffic for control nodes"
  vpc_id = "${aws_vpc.main.id}"

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

resource "aws_security_group" "worker" {
  name = "${var.short_name}-worker"
  description = "Allow inbound traffic for worker nodes"
  vpc_id = "${aws_vpc.main.id}"

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

resource "aws_security_group" "ui" {
  name = "${var.short_name}-ui"
  description = "Allow inbound traffic for Mantl UI"
  vpc_id = "${aws_vpc.main.id}"

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

resource "aws_security_group" "edge" {
  name = "${var.short_name}-edge"
  description = "Allow inbound traffic for edge routing"
  vpc_id = "${aws_vpc.main.id}"

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

resource "aws_key_pair" "deployer" {
  key_name = "key-${var.short_name}"
  public_key = "${file(var.ssh_key)}"
}

output "vpc_subnet" {
  value = "${aws_subnet.main.id}"
}

output "control_security_group" {
  value = "${aws_security_group.control.id}"
}

output "worker_security_group" {
  value = "${aws_security_group.worker.id}"
}

output "ui_security_group" {
  value = "${aws_security_group.ui.id}"
}

output "default_security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

output "control_ids" {
  value = "${join(\",\", aws_instance.mi-control-nodes.*.id)}"
}

output "control_ips" {
  value = "${join(\",\", aws_instance.mi-control-nodes.*.public_ip)}"
}

output "worker_ips" {
  value = "${join(\",\", aws_instance.mi-worker-nodes.*.public_ip)}"
}

output "edge_ips" {
  value = "${join(\",\", aws_instance.mi-edge-nodes.*.public_ip)}"
}
