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

# Example setup for DNS:
# module "dnsimple-dns" { # This could also be "google-cloud-dns"
#   source = "./terraform/dnsimple/dns" # This could also be "./terraform/gce/dns"
#   short_name = "mi"
#   control_count = 3
#   worker_count = 3
#   domain = "example.com"
#   control_ips = "${module.softlayer-hosts.control_ips}"
#   worker_ips = "${module.softlayer-hosts.worker_ips}"
#   # managed_zone = "my-managed-zone" # would be required for Google cloud DNS
# }
