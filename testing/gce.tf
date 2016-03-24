variable "build_number" {}

provider "google" {
  account_file = ""
  region = "us-central1"
  project = "mantl-ci"
}

module "mantl-ci-dc" {
  source = "./terraform/gce"
  datacenter = "mantl-dc"
  control_type = "n1-standard-1"
  worker_type = "n1-highcpu-2"
  network_ipv4 = "10.0.0.0/16"
  long_name = "ciscocloud-mantl-ci-${var.build_number}"
  short_name = "mantl-ci-${var.build_number}"
  region = "us-central1"
  zone = "us-central1-a"
  control_count = 3
  worker_count = 3
  edge_count = 2
}
