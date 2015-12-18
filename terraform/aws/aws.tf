variable "short_name" {default = "mantl-dev"}
variable "datacenter" {default = "aws-us-west-2"}

provider "aws" {
  region = "us-west-2"
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

module "aws-instances" {
  source = "./instances"
  availability_zone = "us-east-1e"
  datacenter = "${var.datacenter}"
  ssh_username = "centos"
  source_ami = "ami-d440a6e7"
  short_name = "${var.short_name}"
  ssh_key_pair = "key-mantl-dev"
  availability_zone = "${terraform_remote_state.vpc.output.availability_zone}"
  aws_vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"
  aws_default_security_group_id = "${terraform_remote_state.vpc.output.default_security_group}"
  aws_vpc_subnet_id = "${terraform_remote_state.vpc.output.vpc_subnet}" 
}
