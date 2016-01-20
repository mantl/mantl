variable "availability_zones"  {
  default = "a,b,c" 
}
variable "control_count" { default = 2 }
variable "datacenter" {default = "aws-us-west-2"}
variable "edge_count" { default = 2 }
variable "region" {default = "us-west-2"}
variable "short_name" {default = "mantl"}
variable "source_ami" {default ="ami-d440a6e7"}
variable "ssh_username" {default = "centos"}
variable "worker_count" { default = 2 }


provider "aws" {
  region = "${var.region}"
}

# _local is for development only s3 or something else should be used
# https://github.com/hashicorp/terraform/blob/master/state/remote/remote.go#L47
# https://www.terraform.io/docs/state/remote.html
#resource "terraform_remote_state" "vpc" {
#  backend = "_local"
#  config {
#    path = "./vpc/terraform.tfstate"
#  }
# }

# s3 example
#resource  "terraform_remote_state" "vpc" {
# backend = "s3"
#  config {
#    bucket = "mybucketname"
#   key = "name_of_state_file"
#  }
#}

module "vpc" {
  source ="./terraform/aws/vpc"
  availability_zones = "${var.availability_zones}"
  short_name = "${var.short_name}"
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
  ssh_username = "${var.ssh_username}"
  source_ami = "${var.source_ami}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.ui_security_group},${module.security-groups.control_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}" 
  # uncomment below it you want to use remote state for vpc variables
  #availability_zones = "${terraform_remote_state.vpc.output.availability_zones}" 
  #security_group_ids = "${terraform_remote_state.vpc.output.default_security_group},${module.security-groups.ui_security_group},${module.security-groups.control_security_group}"
  #vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  #vpc_subnet_ids = "${terraform_remote_state.vpc.output.subnet_ids}" 
}

module "edge-nodes" {
  source = "./terraform/aws/instance"
  count = "${var.edge_count}"
  datacenter = "${var.datacenter}"
  role = "control"
  ssh_username = "${var.ssh_username}"
  source_ami = "${var.source_ami}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.edge_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}" 
  # uncomment below it you want to use remote state for vpc variables
  #availability_zones = "${terraform_remote_state.vpc.output.availability_zones}" 
  #security_group_ids = "${terraform_remote_state.vpc.output.default_security_group},${module.security-groups.edge_security_group}"
  #vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  #vpc_subnet_ids = "${terraform_remote_state.vpc.output.subnet_ids}" 
}

module "worker-nodes" {
  source = "./terraform/aws/instance"
  count = "${var.worker_count}"
  datacenter = "${var.datacenter}"
  data_ebs_volume_size = "100"
  role = "worker"
  ssh_username = "${var.ssh_username}"
  source_ami = "${var.source_ami}"
  short_name = "${var.short_name}"
  ssh_key_pair = "${module.ssh-key.ssh_key_name}"
  availability_zones = "${module.vpc.availability_zones}"
  security_group_ids = "${module.vpc.default_security_group},${module.security-groups.worker_security_group}"
  vpc_subnet_ids = "${module.vpc.subnet_ids}" 
  # uncomment below it you want to use remote state for vpc variables
  #availability_zones = "${terraform_remote_state.vpc.output.availability_zones}" 
  #security_group_ids = "${terraform_remote_state.vpc.output.default_security_group},${module.security-groups.worker_security_group}"
  #vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  #vpc_subnet_ids = "${terraform_remote_state.vpc.output.subnet_ids}" 
}

module "aws-elb" {
  source = "./terraform/aws/elb"
  short_name = "${var.short_name}"
  instances = "${module.control-nodes.ec2_ids}"
  subnets = "${module.vpc.subnet_ids}" 
  security_groups = "${module.security-groups.ui_security_group},${module.vpc.default_security_group}"
  ## uncomment below it you want to use remote state for vpc variables
  ##subnets = "${terraform_remote_state.vpc.output.subnet_ids}" 
  ##security_groups = "${module.security-groups.ui_security_group},${terraform_remote_state.vpc.output.default_security_group}"
}

module "traefik-elb" {
  source = "./terraform/aws/elb/traefik"
  instances = "${module.edge-nodes.ec2_ids}"
  short_name = "${var.short_name}"
  subnets = "${module.vpc.subnet_ids}" 
  security_groups = "${module.security-groups.ui_security_group},${module.vpc.default_security_group}"
  ## uncomment below it you want to use remote state for vpc variables
  ##subnets = "${terraform_remote_state.vpc.output.subnet_ids}" 
  ##security_groups = "${module.security-groups.ui_security_group},${terraform_remote_state.vpc.output.default_security_group}"
}

module "route53" {
  source = "./terraform/aws/route53/dns"
  control_count = "${var.control_count}"
  control_ips = "${module.control-nodes.ec2_ips}"
  domain = "my-domain.com"
  edge_count = "${var.edge_count}"
  edge_ips = "${module.edge-nodes.ec2_ips}"
  elb_fqdn = "${module.aws-elb.fqdn}"
  hosted_zone_id = "XXXXXXXXXXXX"
  short_name = "${var.short_name}"
  subdomain = ".dev"
  traefik_elb_fqdn = "${module.traefik-elb.fqdn}"
  traefik_zone_id = "${module.traefik-elb.zone_id}"
  worker_count = "${var.worker_count}"
  worker_ips = "${module.worker-nodes.ec2_ips}"
}
