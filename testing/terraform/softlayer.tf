variable build_number {}

provider "softlayer" {
  username = "test_username"
  api_key = "test_api_key"
}

module "softlayer-keypair" {
  source = "./terraform/softlayer/keypair"
  public_key_filename = "~/.ssh/id_rsa.pub"
}

module "softlayer-hosts" {
  source = "./terraform/softlayer/hosts"
  ssh_key = "${module.softlayer-keypair.keypair_id}"

  region_name = "ams01"
  domain = "ci.mantl.io"
  control_count = 3
  worker_count = 2
  edge_count = 1
}
