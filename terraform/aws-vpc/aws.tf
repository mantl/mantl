variable "availability_zones" {
  default = "a,b,c" 
}

variable "cidr_blocks" {
  default = {
    az0 = "10.1.1.0/24"
    az1 = "10.1.2.0/24"
    az2 = "10.1.3.0/24"
  }
}
variable "datacenter" {default = "aws"}
variable "network_ipv4" {default = "10.1.0.0/16"}
variable "network_subnet_ip4" {default = "10.1.0.0/16"}

variable "source_ami" { }
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_username"  {default = "centos"}
variable "long_name" {default = "anners"}

variable "region" {
  description = "AWS region"
  default = "us-west-2"
}



resource "aws_vpc" "main" {
  cidr_block = "${var.network_ipv4}"
  enable_dns_hostnames = true
  tags {
    Name = "${var.long_name}"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id = "${aws_vpc.main.id}"
  count = "${length(split(",", var.availability_zones))}"
  cidr_block = "${lookup(var.cidr_blocks, concat("az", count.index))}"
  availability_zone = "${var.region}${element(split(",", var.availability_zones), count.index)}"
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


