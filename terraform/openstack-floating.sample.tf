module "dc2-keypair" {
  source = "./terraform/openstack/keypair"
  auth_url = ""
  tenant_id = ""
  tenant_name = ""
  public_key = ""
  keypair_name = ""
}

module "dc2-hosts-floating" {
  source = "./terraform/openstack/hosts-floating"
  auth_url = ""
  datacenter = "dc2"
  tenant_id = ""
  tenant_name = ""
  control_flavor_name = ""
  worker_flavor_name  = ""
  edge_flavor_name  = ""
  image_name = ""
  ssh_user = "centos"
  keypair_name = "${ module.dc2-keypair.keypair_name }"
  control_count = 3
  worker_count = 3
  edge_count = 2
  floating_pool = ""
  external_net_id = ""
  control_data_volume_size = 20
  worker_data_volume_size = 100
  edge_data_volume_size = 20
}
