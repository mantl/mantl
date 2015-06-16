module "dc2-keypair" {
	source = "./terraform/openstack/keypair"
	auth_url = ""
	tenant_id = ""
	tenant_name = ""
	public_key = ""
	keypair_name = ""
}

module "dc2-hosts" {
	source = "./terraform/openstack/hosts"
	auth_url = ""
	datacenter = "dc2"
	tenant_id = ""
	tenant_name = ""
	control_flavor_name = ""
	resource_flavor_name  = ""
	net_id = ""
	image_name = ""
	keypair_name = "${ module.dc2-keypair.keypair_name }"
	control_count = 2
	resource_count = 3
	security_groups = ""
}
