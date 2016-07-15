variable "build_number" {}

variable "datacenter" {default = "mantl-aws"}
variable "region" {default = "us-west-1"}
variable "ssh_username" {default = "centos"}

provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source ="./terraform/aws/vpc"
  availability_zones = "a,b,c"
  short_name = "mantl-ci-${var.build_number}"
  long_name = "mantl-ci-${var.build_number}"
  region = "${var.region}"
}

module "ssh-key" {
  source ="./terraform/aws/ssh"
  short_name = "mantl-ci-${var.build_number}"
}

module "security-groups" {
  source = "./terraform/aws/security_groups"
  short_name = "mantl-ci-${var.build_number}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "control-nodes" {
  source = "./terraform/aws/instance"
  count = 3
  datacenter = "${var.datacenter}"
  role = "control"
  ec2_type = "m3.medium"
  ssh_username = "${var.ssh_username}"
  source_ami = "ami-af4333cf"
  short_name = "mantl-ci-${var.build_number}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.ui_security_group},${module.security-groups.control_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

module "edge-nodes" {
  source = "./terraform/aws/instance"
  count = 1
  datacenter = "${var.datacenter}"
  role = "edge"
  ec2_type = "m3.medium"
  ssh_username = "${var.ssh_username}"
  source_ami = "ami-af4333cf"
  short_name = "mantl-ci-${var.build_number}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.edge_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

module "worker-nodes" {
  source = "./terraform/aws/instance"
  count = 2
  count_format = "%03d"
  datacenter = "${var.datacenter}"
  data_ebs_volume_size = "20"
  role = "worker"
  ec2_type = "m3.medium"
  ssh_username = "${var.ssh_username}"
  source_ami = "ami-af4333cf"
  short_name = "mantl-ci-${var.build_number}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.worker_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

module "kubeworker-nodes" {
  source = "./terraform/aws/instance"
  count = 2
  count_format = "%03d"
  datacenter = "${var.datacenter}"
  data_ebs_volume_size = "20"
  role = "kubeworker"
  ec2_type = "m3.medium"
  ssh_username = "${var.ssh_username}"
  source_ami = "ami-af4333cf"
  short_name = "mantl-ci-${var.build_number}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.worker_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}
