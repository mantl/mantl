variable "region" {}

provider "aws" {
  access_key = ""
  secret_key = ""
  region = "${var.region}"
}

module "aws-dc" {
  source = "./terraform/aws"
  availability_zone = "us-east-1e"
  ssh_username = "centos"
  source_ami = "${lookup(var.amis, var.region)}"

  control_count = 3
  worker_count = 3
  edge_count = 2
}
