variable location { default = "CA1" }
variable control_count { default = 1 }
variable worker_count { default = 2 }
variable edge_count { default = 1 }
variable ssh_pass { default = "Green123$" }
variable ssh_key { default = "~/.ssh/id_rsa.pub" }

provider "clc" {
}


# server group
resource "clc_group" "mantl" {
  location_id = "${var.location}"
  name = "mantl"
  parent = "Default Group"
}

module "control-nodes" {
  source = "./terraform/clc/node"
  location = "${var.location}"
  group_id = "${clc_group.mantl.id}"
  role = "control"
  count = "${var.control_count}"
  ssh_pass = "${var.ssh_pass}"
  ssh_key = "${var.ssh_key}"
}

module "edge-nodes" {
  source = "./terraform/clc/node"
  location = "${var.location}"
  group_id = "${clc_group.mantl.id}"
  role = "edge"
  count = "${var.edge_count}"
  ssh_pass = "${var.ssh_pass}"
  ssh_key = "${var.ssh_key}"
}

module "worker-nodes" {
  source = "./terraform/clc/node"
  location = "${var.location}"
  group_id = "${clc_group.mantl.id}"
  role = "worker"
  count = "${var.worker_count}"
  ssh_pass = "${var.ssh_pass}"
  ssh_key = "${var.ssh_key}"
}




