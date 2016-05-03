variable "build_number" {}

variable "control_count" { default = 3 }
variable "datacenter" {default = "mantl-dc"}
variable "edge_count" { default = 1}
variable "image" {default = "centos-7-v20160119"}
variable "long_name" {default = "ciscocloud-mantl-ci-0-0"}
variable "short_name" {default = "mantl-ci-0-0"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_user" {default = "centos"}
variable "kubeworker_count" {default = 0}
variable "worker_count" {default = 2}
variable "control_type" { default = "n1-standard-1" }
variable "edge_type" { default = "n1-standard-1" }
variable "worker_type" { default = "n1-standard-2" }
variable "zones" {
  default = "us-central1-a,us-central1-b"
}

provider "google" {
  project = "mantl-ci"
  region = "us-central1"
}

module "gce-network" {
  source = "./terraform/gce/network"
  network_ipv4 = "10.0.0.0/16"
  long_name = "ciscocloud-mantl-ci-${var.build_number}"
  short_name = "mantl-ci-${var.build_number}"
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
  short_name = "mantl-ci-${var.build_number}"
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
  short_name = "mantl-ci-${var.build_number}"
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
  short_name = "mantl-ci-${var.build_number}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "network-lb" {
  source = "./terraform/gce/lb"
  instances = "${module.edge-nodes.instances}"
  short_name = "mantl-ci-${var.build_number}"
}
