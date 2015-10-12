provider "vsphere" {
  vcenter_server = ""
  user = ""
  password = ""
  insecure_connection = ""
}

module "vsphere-dc" {
  source = "./terraform/vsphere"
  long_name = ""
  short_name = ""
  datacenter = ""
  host = ""
  pool = ""
  template = ""
  control_count = 3
  worker_count = 3
  ssh_user = ""
  ssh_key = ""
  consul_dc = ""
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
