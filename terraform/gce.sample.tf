provider "google" {
  account_file = "${file("account.json")}"
  project = ""
  region = ""
}

module "gce-dc" {
  source = "./terraform/gce"
  datacenter = "gce-dc"
  control_type = "n1-standard-1"
  worker_type = "n1-highcpu-2"
  network_ipv4 = "10.0.0.0/16"
  long_name = "microservices-infrastructure"
  short_name = "mi"
  region = ""
  zone = ""
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
#   control_ips = "${module.gce-dc.control_ips}"
#   worker_ips = "${module.gce-dc.worker_ips}"
# }
