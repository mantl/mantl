# this sample assumes that you have `SDC_ACCOUNT`, `SDC_KEY_MATERIAL`,
# `SDC_KEY_ID`, and `SDC_URL` in your environment from (for example) using the
# Triton command-line utilities. If you don't, set `account`, `key_material`,
# `key_id`, and `url` in the provider below
provider "triton" {}

variable key_path { default = "~/.ssh/id_rsa.pub" }
variable control_count { default = 3 }
variable control_package { default = "Medium 4GB" } # 4GB and 4 VCPUs
variable edge_count { default = 1 }
variable edge_package { default = "Medium 2GB" } # 2GB and 2VCPUs
variable image { default = "dd31507e-031e-11e6-be8a-8f2707b5b3ee" } # centos-7, updated 2016-04-15
variable kubeworker_count { default = 2 }
variable short_name { default = "mantl" }
variable worker_count { default = 2 }
variable worker_package { default = "Large 8GB" } # 8GB and 8 VCPUs
variable public_network { default = "9ec60129-9034-47b4-b111-3026f9b1a10f" } # default public in us-east-1. Find yours with `triton network list`
variable vlan_id { default = 3 }

module "triton-keypair" {
  source = "./terraform/triton/keypair"

  short_name          = "${var.short_name}"
  public_key_material = "${file(var.key_path)}"
}

module "network" {
  source = "./terraform/triton/network"

  short_name = "${var.short_name}"
  vlan_id    = "${var.vlan_id}"
}

module "control-nodes" {
  source = "./terraform/triton/instance"

  count           = "${var.control_count}"
  image           = "${var.image}"
  keys            = "${file(var.key_path)}"
  package         = "${var.control_package}"
  role            = "control"
  short_name      = "${var.short_name}"
  public_network  = "${var.public_network}"
  private_network = "${module.network.network_id}"
}

module "worker-nodes" {
  source = "./terraform/triton/instance"

  count           = "${var.worker_count}"
  image           = "${var.image}"
  keys            = "${file(var.key_path)}"
  package         = "${var.worker_package}"
  role            = "worker"
  short_name      = "${var.short_name}"
  public_network  = "${var.public_network}"
  private_network = "${module.network.network_id}"
}

module "kubeworker-nodes" {
  source = "./terraform/triton/instance"

  count           = "${var.kubeworker_count}"
  image           = "${var.image}"
  keys            = "${file(var.key_path)}"
  package         = "${var.worker_package}"
  role            = "kubeworker"
  short_name      = "${var.short_name}"
  public_network  = "${var.public_network}"
  private_network = "${module.network.network_id}"
}

module "edge-nodes" {
  source = "./terraform/triton/instance"

  count           = "${var.edge_count}"
  image           = "${var.image}"
  keys            = "${file(var.key_path)}"
  package         = "${var.edge_package}"
  role            = "edge"
  short_name      = "${var.short_name}"
  public_network  = "${var.public_network}"
  private_network = "${module.network.network_id}"
}
