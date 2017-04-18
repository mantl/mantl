# All of your resources will be prefixed by this name
variable "name" { default = "mantl" }
variable "region" { default = "nyc3" } # Must have metadata support

provider "digitalocean" {
  token = ""
}

module "do-keypair" {
  name = "${var.name}"
  source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "control-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "${var.name}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "control"
  count = "3"
}

module "worker-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "${var.name}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "worker"
}

module "kubeworker-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "${var.name}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "kubeworker"
}

module "edge-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "${var.name}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "edge"
  count = "1"
  size = "2gb"
}
