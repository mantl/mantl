provider "digitalocean" {
  token = ""
}

module "do-keypair" {
	source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "do-hosts" {
  source = "./terraform/digitalocean/hosts"
  ssh_key = "${module.do-keypair.keypair_id}"

  region_name = "nyc3" # this must be a region with metadata support
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
