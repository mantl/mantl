variable "build_number" {}

provider "digitalocean" {
}

module "do-drone-keypair" {
  source = "./terraform/digitalocean/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "do-drone-hosts" {
  source = "./terraform/digitalocean/hosts"
  ssh_key = "${module.do-drone-keypair.keypair_id}"
  region_name = "nyc3" # this must be a region with metadata support
  short_name = "drone-ci-${var.build_number}"

  control_count = 3
  worker_count = 3
  edge_count = 2
}
