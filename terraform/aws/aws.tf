variable "cluster_id" { }
variable "network_ipv4" {default = "10.0.0.0/16"}
variable "network_subnet_ip4" {default = "10.0.0.0/16"}
variable "control_count" {default = "3"}
variable "worker_count" {default = "1"}
variable "control_type" {default = "m1.small"}
variable "source_ami" { }
variable "worker_type" {default = "m1.small"}
variable "public_key" { }
variable "availability_zone" {}

resource "aws_vpc" "main" {
  cidr_block = "${var.network_ipv4}"
}

resource "aws_subnet" "main" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.network_subnet_ip4}"
  availability_zone = "${var.availability_zone}"
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

resource "aws_instance" "mi-control-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.control_type}"
  count = "${var.control_count}"
  vpc_security_group_ids = ["${aws_security_group.external.id}",
    "${aws_vpc.main.default_security_group_id}"]

  key_name = "${aws_key_pair.deployer.key_name}"

  associate_public_ip_address=true

  subnet_id = "${aws_subnet.main.id}"

  tags {
    Name = "${var.cluster_id}_terraform_control"
  }
}

resource "aws_instance" "mi-worker-nodes" {
  ami = "${var.source_ami}"
  availability_zone = "${var.availability_zone}"
  instance_type = "${var.worker_type}"
  count = "${var.worker_count}"

  vpc_security_group_ids = ["${aws_security_group.external.id}",
    "${aws_vpc.main.default_security_group_id}"]


  key_name = "${aws_key_pair.deployer.key_name}"

  subnet_id = "${aws_subnet.main.id}"

  tags {
    Name = "${var.cluster_id}_terraform_worker"
  }
}

resource "aws_security_group" "allow_all_icmp" {
  name = "allow_all_icmp_${var.cluster_id}"
  description = "Allow all icmp traffic"

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_icmp"
  }
}

resource "aws_security_group" "allow_all_ssh" {
  name = "allow_all_ssh_${var.cluster_id}"
  description = "Allow ssh traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_all_tcp_within_subnet" {
  name = "allow_all_tcp_within_subnet_${var.cluster_id}"
  description = "Allow all tcp traffic within our subnet"

  vpc_id="${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.network_subnet_ip4}"]
  }

  tags {
    Name = "allow_all_tcp"
  }
}

resource "aws_security_group" "allow_all_udp_within_subnet" {
  name = "allow_all_udp_within_subnet_${var.cluster_id}"
  description = "Allow all traffic within our subnet"

  vpc_id="${aws_vpc.main.id}"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    cidr_blocks = ["${var.network_subnet_ip4}"]
  }

  tags {
    Name = "allow_all_upp"
  }
}


resource "aws_security_group" "external" {
  name = "master_group_${var.cluster_id}"
  description = "Allow all inbound traffic"

  vpc_id="${aws_vpc.main.id}"

  tags {
    Name = "${var.cluster_id}_terraform"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.external.id}"
}
resource "aws_security_group_rule" "allow_rdp" {
  type = "ingress"
  from_port = 3389
  to_port = 3389
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.external.id}"
}
resource "aws_security_group_rule" "allow_mesos" {
  type = "ingress"
  from_port = 5050
  to_port = 5050
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.external.id}"
}

resource "aws_security_group_rule" "allow_marathon" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.external.id}"
}

resource "aws_security_group_rule" "allow_icmp" {
  type = "ingress"
  from_port=-1
  to_port=-1
  protocol = "icmp"
  cidr_blocks=["0.0.0.0/0"]

  security_group_id = "${aws_security_group.external.id}"
}

resource "aws_key_pair" "deployer" {
  key_name = "key-${var.cluster_id}"
  public_key = "${var.public_key}"
}
