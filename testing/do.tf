variable "build_number" {}

provider "digitalocean" {
}

module "do-mantl-keypair" {
  source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "do-mantl-hosts" {
  source = "./terraform/digitalocean/hosts"
  ssh_key = "${module.do-mantl-keypair.keypair_id}"
  region_name = "sfo1" # this must be a region with metadata support
  short_name = "mantl-ci-${var.build_number}"

  control_count = 3
  worker_count = 3
  edge_count = 2
}
