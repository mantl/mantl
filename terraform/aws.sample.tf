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

# Example setup for DNS:
# module "dnsimple-dns" { # This could also be "google-cloud-dns"
#   source = "./terraform/dnsimple/dns" # This could also be "./terraform/gce/dns"
#   short_name = "mi"
#   control_count = 3
#   worker_count = 3
#   domain = "example.com"
#   control_ips = "${module.aws-dc.control_ips}"
#   worker_ips = "${module.aws-dc.worker_ips}"
#   # managed_zone = "my-managed-zone" # would be required for Google cloud DNS
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

# Example setup for an AWS ELB
# module "aws-elb" {
#   source = "./terraform/aws-elb"
#   short_name = "mi"
#   instances = "${module.aws-dc.control_ids}"
#   subnets = "${module.aws-dc.vpc_subnet}"
#   security_groups = "${module.aws-dc.ui_security_group},${module.aws-dc.default_security_group}"
# }
