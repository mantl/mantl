provider "aws" {
  access_key = ""
  secret_key = ""
  region = ""
}

module "aws-dc" {
  source = "./terraform/aws"
  availability_zone = "us-east-1e"
  ssh_username = "centos"
  source_ami = "ami-96a818fe"

  control_count = 3
  worker_count = 3
  edge_count = 2
}
