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
  control_count = 3
  worker_count = 3
}

# Example setup for DNS with dnsimple;
# module "dnsimple-dns" {
#   source = "./terraform/dnsimple/dns"
#   short_name = "mi"
#   control_count = 3
#   worker_count = 3
#   domain = "example.com"
#   control_ips = "${module.aws-dc.control_ips}"
#   worker_ips = "${module.aws-dc.worker_ips}"
# }

# Example setup for DNS with route53;
# module "route53-dns" {
#   source = "./terraform/route53/dns"
#   short_name = "mi"
#   control_count = 3
#   worker_count = 3
#   domain = "example.com"
#   hosted_zone_id = "XXXXXXXXX"
#   control_ips = "${module.aws-dc.control_ips}"
#   worker_ips = "${module.aws-dc.worker_ips}"
# }
