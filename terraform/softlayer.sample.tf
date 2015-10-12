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

# Example setup for DNS:
# module "dnsimple-dns" { # This could also be "google-cloud-dns"
#   source = "./terraform/dnsimple/dns" # This could also be "./terraform/gce/dns"
#   short_name = "mi"
#   control_count = 3
#   worker_count = 3
#   domain = "example.com"
#   control_ips = "${module.softlayer-hosts.control_ips}"
#   worker_ips = "${module.softlayer-hosts.worker_ips}"
#   # managed_zone = "my-managed-zone" # this would be required for Google cloud DNS
# }
