variable "control_count" { default = 3 }
variable "worker_count" { default = 2 }
variable "edge_count" { default = 2 }
variable "datacenter" {default = "aws-us-west-2"}
variable "region" {default = "us-west-2"}
variable "short_name" {default = "mantl-ELBtesting"}
variable "source_ami" {default ="ami-d440a6e7"}
variable "ssh_username" {default = "centos"}


provider "aws" {
  region = "${var.region}"
}

# _local is for development only s3 or something else should be used
# https://github.com/hashicorp/terraform/blob/master/state/remote/remote.go#L47
# https://www.terraform.io/docs/state/remote.html
resource "terraform_remote_state" "vpc" {
  backend = "_local"
  config {
    path = "./vpc/terraform.tfstate"
  }
}

# s3 example
#resource  "terraform_remote_state" "vpc" {
# backend = "s3"
#  config {
#    bucket = "mybucketname"
#   key = "name_of_state_file"
#  }
#}

#module "vpc" {
#  source ="./vpc"
#  short_name = "${var.short_name}"
#  region = "${var.region}"
#}

module "ssh-key" {
  source ="./ssh"
  short_name = "${var.short_name}"
}

module "control-nodes" {
  source = "./nodes/control"
  control_count = "${var.control_count}"
  datacenter = "${var.datacenter}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${var.source_ami}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  default_security_group_id = "${terraform_remote_state.vpc.output.default_security_group}"
  vpc_subnet_ids = "${terraform_remote_state.vpc.output.subnet_ids}" 
  availability_zones = "${terraform_remote_state.vpc.output.availability_zones}" 
}

module "edge-nodes" {
 source = "./nodes/edge"
  datacenter = "${var.datacenter}"
  edge_count = "${var.edge_count}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${var.source_ami}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${terraform_remote_state.vpc.output.availability_zones}"
  vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  default_security_group_id = "${terraform_remote_state.vpc.output.default_security_group}"
  vpc_subnet_ids = "${terraform_remote_state.vpc.output.subnet_ids}" 
}

module "worker-nodes" {
  source = "./nodes/worker"
  datacenter = "${var.datacenter}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${var.source_ami}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${terraform_remote_state.vpc.output.availability_zones}"
  vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  default_security_group_id = "${terraform_remote_state.vpc.output.default_security_group}"
  vpc_subnet_ids = "${terraform_remote_state.vpc.output.subnet_ids}"
  worker_count = "${var.worker_count}"  
}

module "aws-elb" {
  source = "./elb"
  short_name = "${var.short_name}"
  instances = "${module.control-nodes.control_ids}"
  subnets = "${terraform_remote_state.vpc.output.subnet_ids}" 
  security_groups = "${module.control-nodes.ui_security_group},${terraform_remote_state.vpc.output.default_security_group}"
}

module "route53" {
  source = "./route53/dns"
  control_count = "${var.control_count}"
  control_ips = "${module.control-nodes.control_ips}"
  domain = "my-test-cloud.com"
  edge_count = "${var.edge_count}"
  edge_ips = "${module.edge-nodes.edge_ips}"
  elb_fqdn = "${module.aws-elb.fqdn}"
  hosted_zone_id = "XXXXXXXXXXXX"
  short_name = "${var.short_name}"
  subdomain = ".dev"
  worker_count = "${var.worker_count}"
  worker_ips = "${module.worker-nodes.worker_ips}"
}
