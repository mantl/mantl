variable "amis" {
	default = {
		us-east-1      = "ami-61bbf104"
		us-west-2      = "ami-d440a6e7"
		us-west-1      = "ami-f77fbeb3"
		eu-central-1   = "ami-e68f82fb"
		eu-west-1      = "ami-33734044"
		ap-southeast-1 = "ami-2a7b6b78"
		ap-southeast-2 = "ami-d38dc6e9"
		ap-northeast-1 = "ami-b80b6db8"
		sa-east-1      = "ami-fd0197e0"
	}
}
variable "region" { default = "us-east-1" }

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
