provider "google" {
  account_file = "account.json"
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
  control_count = 2
  worker_count = 3
}
