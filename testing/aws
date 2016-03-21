variable "build_number" {}

provider "aws" {
  region = "us-west-1"
}

module "aws-mantl-testing" {
  source = "./terraform/aws"
  availability_zone = "us-west-1b"
  ssh_username = "centos"
  source_ami = "ami-af4333cf"
  short_name = "mantl-ci-${var.build_number}"
  long_name = "ciscocloud-mantl-ci-${var.build_number}"

  control_count = 3
  worker_count = 3
  edge_count = 2
}
