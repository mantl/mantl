variable "availability_zone" {default = "a"}
variable "datacenter" {default = "aws"}
variable "long_name" {default = "microservices-infastructure"}
variable "network_ipv4" {default = "10.1.0.0/21"}
variable "network_subnet_ip4" {default = "10.1.0.0/21"}
variable "short_name" {default = "mantl"}
variable "region" {default = "us-west-2"}


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
  availability_zone = "${var.region}${var.availability_zone}"
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

output "availability_zone" {
  value = "${aws_subnet.main.availability_zone}"
}

output "vpc_subnet" {
  value = "${aws_subnet.main.id}"
}

output "default_security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}
