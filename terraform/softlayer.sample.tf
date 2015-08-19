provider "softlayer" {
}

module "softlayer-keypair" {
  source = "./terraform/softlayer/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "softlayer-hosts" {
  source = "./terraform/softlayer/hosts"
  ssh_key = "${module.softlayer-keypair.keypair_id}"

  region_name = "ams01"
  domain = "example.com"
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
#   control_ips = "${module.softlayer-hosts.control_ips}"
#   worker_ips = "${module.softlayer-hosts.worker_ips}"
# }
