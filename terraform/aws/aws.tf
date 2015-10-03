variable "availability_zone" {}
variable "control_count" {default = "3"}
variable "control_type" {default = "m1.small"}
variable "datacenter" {default = "aws"}
variable "glusterfs_volume_size" {default = "100"} # size is in gigabytes
variable "long_name" {default = "microservices-infastructure"}
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "network_subnet_ip4" {default = "10.0.0.0/16"}
variable "short_name" {default = "mi"}
variable "source_ami" { }
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_username"  {default = "centos"}
variable "worker_count" {default = "1"}
variable "worker_type" {default = "m1.small"}
variable "control_volume_size" {default = "20"} # size is in gigabytes
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

resource "aws_ebs_volume" "mi-control-glusterfs" {
  availability_zone = "${var.availability_zone}"
  count = "${var.control_count}"
  size = "${var.glusterfs_volume_size}"
  type = "gp2"

  tags {
    Name = "${var.short_name}-control-glusterfs-${format("%02d", count.index+1)}"
  }
}

resource "aws_instance" "mi-control-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.control_type}"
  count = "${var.control_count}"
  vpc_security_group_ids = ["${aws_security_group.control.id}",
    "${aws_vpc.main.default_security_group_id}"]

  key_name = "${aws_key_pair.deployer.key_name}"

  associate_public_ip_address=true

  subnet_id = "${aws_subnet.main.id}"

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

resource "aws_volume_attachment" "mi-control-nodes-glusterfs-attachment" {
  count = "${var.control_count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.mi-control-nodes.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.mi-control-glusterfs.*.id, count.index)}"
  force_detach = true
}

resource "aws_instance" "mi-worker-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.worker_type}"
  count = "${var.worker_count}"

  vpc_security_group_ids = ["${aws_security_group.worker.id}",
    "${aws_vpc.main.default_security_group_id}"]


  key_name = "${aws_key_pair.deployer.key_name}"

  associate_public_ip_address=true

  subnet_id = "${aws_subnet.main.id}"

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

resource "aws_security_group" "control" {
  name = "${var.short_name}-control"
  description = "Allow inbound traffic for control nodes"
  vpc_id="${aws_vpc.main.id}"

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
    from_port=-1
    to_port=-1
    protocol = "icmp"
    cidr_blocks=["0.0.0.0/0"]
  }

}

resource "aws_security_group" "worker" {
  name = "${var.short_name}-worker"
  description = "Allow inbound traffic for worker nodes"
  vpc_id="${aws_vpc.main.id}"

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
    from_port=-1
    to_port=-1
    protocol = "icmp"
    cidr_blocks=["0.0.0.0/0"]
  }

}

resource "aws_key_pair" "deployer" {
  key_name = "key-${var.short_name}"
  public_key = "${file(var.ssh_key)}"
}

output "control_ips" {
  value = "${join(\",\", aws_instance.mi-control-nodes.*.public_ip)}"
}

output "worker_ips" {
  value = "${join(\",\", aws_instance.mi-worker-nodes.*.public_ip)}"
}
