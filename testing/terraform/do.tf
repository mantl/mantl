variable "build_number" {}
variable "region" { default = "sfo1" } # Must have metadata support

provider "digitalocean" { }

module "do-keypair" {
  name = "ci-${var.build_number}"
  source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "control-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "ci-${var.build_number}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "control"
  count_format = "%02d"
  count = "3"
}

module "worker-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "ci-${var.build_number}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "worker"
}

module "kubeworker-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "ci-${var.build_number}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "kubeworker"
}

module "edge-nodes" {
  source = "./terraform/digitalocean/instance"
  name = "ci-${var.build_number}"
  region = "${var.region}"
  keypair_id = "${module.do-keypair.keypair_id}"

  role = "edge"
  count = "1"
  size = "2gb"
}
