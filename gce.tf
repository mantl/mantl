variable "control_count" { default = 3 }
variable "datacenter" {default = "gce"}
variable "edge_count" { default = 3}
variable "image" {default = "centos-7-v20150526"}
variable "long_name" {default = "microservices-infastructure"}
variable "short_name" {default = "mi"}
variable "ssh_key" {default = "~/.ssh/id_rsa.pub"}
variable "ssh_user" {default = "centos"}
variable "worker_count" {default = 1}
variable "zones" {
  default = "us-central1-a,us-central1-b"
}

provider "google" {
	account_file = ""
  	credentials = "${file("account.json")}"
  	project = "mantl-1180"
  	region = "us-central1"
}

#module "gce-network" {
#	source = "./terraform/gce/network"
#	network_ipv4 = "10.0.0.0/16"
#}

resource "terraform_remote_state" "gce-network" {
	backend = "_local"
	config {
		path = "./terraform/gce/network/terraform.tfstate"
	}
}

module "control-nodes" {
	source = "./terraform/gce/nodes/control"
	control_count = "${var.control_count}"
  datacenter = "${var.datacenter}"
  image = "${var.image}"
  long_name = "${var.long_name}"
  network_name = "${terraform_remote_state.gce-network.output.network_name}"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "edge-nodes" {
  source = "./terraform/gce/nodes/edge"
  edge_count = "${var.edge_count}"
  datacenter = "${var.datacenter}"
  image = "${var.image}"
  long_name = "${var.long_name}"
  network_name = "${terraform_remote_state.gce-network.output.network_name}"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}

module "worker-nodes" {
  source = "./terraform/gce/nodes/worker"
  worker_count = "${var.worker_count}"
  datacenter = "${var.datacenter}"
  image = "${var.image}"
  long_name = "${var.long_name}"
  network_name = "${terraform_remote_state.gce-network.output.network_name}"
  short_name = "${var.short_name}"
  ssh_user = "${var.ssh_user}"
  ssh_key = "${var.ssh_key}"
  zones = "${var.zones}"
}
