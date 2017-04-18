variable "count" {default = "4"}
variable "count_format" {default = "%02d"}
variable "iam_profile" {default = "" }
variable "ec2_type" {default = "m3.medium"}
variable "ebs_volume_size" {default = "20"} # size is in gigabytes
variable "ebs_volume_type" {default = "gp2"}
variable "data_ebs_volume_size" {default = "20"} # size is in gigabytes
variable "data_ebs_volume_type" {default = "gp2"}
variable "role" {}
variable "short_name" {default = "mantl"}
variable "availability_zones" {}
variable "ssh_key_pair" {}
variable "datacenter" {}
variable "source_ami" {}
variable "security_group_ids" {}
variable "vpc_subnet_ids" {}
variable "ssh_username" {default = "centos"}


resource "aws_ebs_volume" "ebs" {
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count = "${var.count}"
  size = "${var.data_ebs_volume_size}"
  type = "${var.data_ebs_volume_type}"

  tags {
    Name = "${var.short_name}-${var.role}-lvm-${format(var.count_format, count.index+1)}"
    KubernetesCluster = "${var.short_name}"
  }
}


resource "aws_instance" "instance" {
  ami = "${var.source_ami}"
  instance_type = "${var.ec2_type}"
  count = "${var.count}"
  vpc_security_group_ids = [ "${split(",", var.security_group_ids)}"]
  key_name = "${var.ssh_key_pair}"
  associate_public_ip_address = true
  subnet_id = "${element(split(",", var.vpc_subnet_ids), count.index)}"
  iam_instance_profile = "${var.iam_profile}"
  root_block_device {
    delete_on_termination = true
    volume_size = "${var.ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }


  tags {
    Name = "${var.short_name}-${var.role}-${format(var.count_format, count.index+1)}"
    sshUser = "${var.ssh_username}"
    role = "${var.role}"
    dc = "${var.datacenter}"
    KubernetesCluster = "${var.short_name}"
  }
}


resource "aws_volume_attachment" "instance-lvm-attachment" {
  count = "${var.count}"
  device_name = "xvdh"
  instance_id = "${element(aws_instance.instance.*.id, count.index)}"
  volume_id = "${element(aws_ebs_volume.ebs.*.id, count.index)}"
  force_detach = true
}



output "hostname_list" {
  value = "${join(",", aws_instance.instance.*.tags.Name)}"
}

output "ec2_ids" {
  value = "${join(",", aws_instance.instance.*.id)}"
}

output "ec2_ips" {
  value = "${join(",", aws_instance.instance.*.public_ip)}"
}
