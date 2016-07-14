variable "build_number" {}

variable "amis" {
  default = {
    us-east-1      = "ami-6d1c2007"
    us-west-2      = "ami-d2c924b2"
    us-west-1      = "ami-af4333cf"
    eu-central-1   = "ami-9bf712f4"
    eu-west-1      = "ami-7abd0209"
    ap-southeast-1 = "ami-f068a193"
    ap-southeast-2 = "ami-fedafc9d"
    ap-northeast-1 = "ami-eec1c380"
    sa-east-1      = "ami-26b93b4a"
  }
}
variable "availability_zones"  {
  default = "a,b,c"
}
variable "control_count" { default = 3 }
variable "datacenter" {default = "aws-us-west-2"}
variable "edge_count" { default = 1 }
variable "region" {default = "us-west-1"}
variable "short_name" {default = "mantl-ci-${var.build_number}"}
variable "long_name" {default = "mantl-ci-${var.build_number}"}
variable "ssh_username" {default = "centos"}
variable "worker_count" { default = 2 }
variable "kubeworker_count" { default = 2 }
variable "dns_subdomain" { default = ".dev" }
variable "control_type" { default = "m3.medium" }
variable "edge_type" { default = "m3.medium" }
variable "worker_type" { default = "m3.medium" }
variable "kubeworker_type" { default = "m3.medium" }

provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source ="./terraform/aws/vpc"
  availability_zones = "${var.availability_zones}"
  short_name = "${var.short_name}"
  long_name = "${var.long_name}"
  region = "${var.region}"
}

module "ssh-key" {
  source ="./terraform/aws/ssh"
  short_name = "${var.short_name}"
}

module "security-groups" {
  source = "./terraform/aws/security_groups"
  short_name = "${var.short_name}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "control-nodes" {
  source = "./terraform/aws/instance"
  count = "${var.control_count}"
  datacenter = "${var.datacenter}"
  role = "control"
  ec2_type = "${var.control_type}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${lookup(var.amis, var.region)}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.ui_security_group},${module.security-groups.control_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

module "edge-nodes" {
  source = "./terraform/aws/instance"
  count = "${var.edge_count}"
  datacenter = "${var.datacenter}"
  role = "edge"
  ec2_type = "${var.edge_type}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${lookup(var.amis, var.region)}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.edge_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

module "worker-nodes" {
  source = "./terraform/aws/instance"
  count = "${var.worker_count}"
  count_format = "%03d"
  datacenter = "${var.datacenter}"
  data_ebs_volume_size = "20"
  role = "worker"
  ec2_type = "${var.worker_type}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${lookup(var.amis, var.region)}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.worker_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

module "kubeworker-nodes" {
  source = "./terraform/aws/instance"
  count = "${var.kubeworker_count}"
  count_format = "%03d"
  datacenter = "${var.datacenter}"
  data_ebs_volume_size = "20"
  role = "kubeworker"
  ec2_type = "${var.kubeworker_type}"
  ssh_username = "${var.ssh_username}"
  source_ami = "${lookup(var.amis, var.region)}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.worker_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}"
}

# TODO: waiting on #1688
# module "aws-elb" {
#   source = "./terraform/aws/elb"
#   short_name = "${var.short_name}"
#   instances = "${module.control-nodes.ec2_ids}"
#   subnets = "${module.vpc.subnet_ids}"
#   security_groups = "${module.security-groups.ui_security_group},${module.vpc.default_security_group}"
#   ## uncomment below it you want to use remote state for vpc variables
#   ##subnets = "${terraform_remote_state.vpc.output.subnet_ids}"
#   ##security_groups = "${module.security-groups.ui_security_group},${terraform_remote_state.vpc.output.default_security_group}"
# }

# module "traefik-elb" {
#   source = "./terraform/aws/elb/traefik"
#   instances = "${module.edge-nodes.ec2_ids}"
#   short_name = "${var.short_name}"
#   subnets = "${module.vpc.subnet_ids}"
#   security_groups = "${module.security-groups.ui_security_group},${module.vpc.default_security_group}"
#   ## uncomment below it you want to use remote state for vpc variables
#   ##subnets = "${terraform_remote_state.vpc.output.subnet_ids}"
#   ##security_groups = "${module.security-groups.ui_security_group},${terraform_remote_state.vpc.output.default_security_group}"
# }
