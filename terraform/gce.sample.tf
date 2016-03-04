variable "control_count" { default = 3 }
variable "datacenter" {default = "gce"}
variable "edge_count" { default = 1}
variable "image" {default = "centos-7-v20160119"}
variable "long_name" {default = "mantl"}
variable "short_name" {default = "mi"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_user" {default = "centos"}
variable "worker_count" {default = 4}
variable "control_type" { default = "n1-standard-1" }
variable "edge_type" { default = "n1-standard-1" }
variable "worker_type" { default = "n1-standard-2" }
variable "zones" {
  default = "us-central1-a,us-central1-b"
}

provider "google" {
  credentials = "${file("account.json")}"
  project = ""
  region = "us-central1"
}

module "gce-network" {
  source = "./terraform/gce/network"
  network_ipv4 = "10.0.0.0/16"
  long_name = "${var.long_name}"
  short_name = "${var.short_name}"
}

# remote state example
# _local is for development only s3 or something else should be used
# https://github.com/hashicorp/terraform/blob/master/state/remote/remote.go#L47
# https://www.terraform.io/docs/state/remote.html
#resource "terraform_remote_state" "gce-network" {
#  backend = "_local"
#  config {
#    path = "./terraform/gce/network/terraform.tfstate"
#  }
#}


module "control-nodes" {
  source = "./terraform/gce/instance"
  count = "${var.control_count}"
  datacenter = "${var.datacenter}"
  image = "${var.image}"
  machine_type = "${var.control_type}"
  network_name = "${module.gce-network.network_name}"
  #network_name = "${terraform_remote_state.gce-network.output.network_name}"
  role = "control"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "edge-nodes" {
  source = "./terraform/gce/instance"
  count = "${var.edge_count}"
  datacenter = "${var.datacenter}"
  image = "${var.image}"
  machine_type = "${var.edge_type}"
  network_name = "${module.gce-network.network_name}"
  #network_name = "${terraform_remote_state.gce-network.output.network_name}"
  role = "edge"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "worker-nodes" {
  source = "./terraform/gce/instance"
  count = "${var.worker_count}"
  datacenter = "${var.datacenter}"
  image = "${var.image}"
  machine_type = "${var.worker_type}"
  network_name = "${module.gce-network.network_name}"
  #network_name = "${terraform_remote_state.gce-network.output.network_name}"
  role = "worker"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "network-lb" {
  source = "./terraform/gce/lb"
  instances = "${module.edge-nodes.instances}"
  short_name = "${var.short_name}"
}

module "cloud-dns" {
  source = "./terraform/gce/dns"
  control_count = "${var.control_count}"
  control_ips = "${module.control-nodes.gce_ips}"
  domain = "mydomain.com"
  edge_count = "${var.edge_count}"
  edge_ips = "${module.edge-nodes.gce_ips}"
  lb_ip = "${module.network-lb.public_ip}"
  managed_zone = "my-cloud-dns-zone"
  short_name = "${var.short_name}"
  subdomain = ".service"
  worker_count = "${var.worker_count}"
  worker_ips = "${module.worker-nodes.gce_ips}"
}
