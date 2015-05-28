provider "aws" {
  access_key = ""
  secret_key = ""
  region = ""
}

module "aws-dc" {
  source = "./terraform/aws"
  availability_zone = "us-east-1e"
  control_type = "t2.small"
  worker_type = "t2.small"
  ssh_username = "centos"
  source_ami = "ami-96a818fe"
  control_count = 2
  worker_count = 3
}
