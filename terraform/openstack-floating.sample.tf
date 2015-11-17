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
  resource_flavor_name  = ""
  image_name = ""
  keypair_name = "${ module.dc2-keypair.keypair_name }"
  control_count = 3
  resource_count = 3
  edge_count = 2
	floating_pool = ""
	external_net_id = ""
}

# Example setup for DNS:
# module "dnsimple-dns" { # This could also be "google-cloud-dns"
#   source = "./terraform/dnsimple/dns" # This could also be "./terraform/gce/dns"
#   short_name = "mi"
#   control_count = 3
#   worker_count = 3
#   domain = "example.com"
#   control_ips = "${module.dc2-hosts-floating.control_ips}"
#   worker_ips = "${module.dc2-hosts-floating.worker_ips}"
#   # managed_zone = "my-managed-zone" # would be required for Google cloud DNS
# }
