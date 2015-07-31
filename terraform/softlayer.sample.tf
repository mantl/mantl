provider "softlayer" {
}

module "softlayer-keypair" {
  source = "./terraform/softlayer/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "softlayer-hosts" {
  source = "./terraform/softlayer/hosts"
  ssh_key = "${module.softlayer-keypair.keypair_id}"

  region_name = "ams01"
  domain = "example.com"
  control_count = 1
  worker_count = 3
}
