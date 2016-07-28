variable "build_number" {}

provider "digitalocean" {
}

module "do-mantl-keypair" {
  name = "ci-${var.build_number}"
  source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "do-mantl-hosts" {
  name = "ci-${var.build_number}"
  source = "./terraform/digitalocean/hosts"
  ssh_key = "${module.do-mantl-keypair.keypair_id}"
  region_name = "sfo1" # this must be a region with metadata support

  control_count = 3
  worker_count = 2
  edge_count = 1
  kubeworker_count = 2
}
