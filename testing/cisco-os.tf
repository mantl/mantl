variable build_number {}

variable subnet_cidr { default = "10.0.0.0/24" }
variable public_key { default = "~/.ssh/id_rsa.pub" }

variable control_count { default = "3"} # mesos masters, zk leaders, consul servers
variable worker_count { default = "1"}  # worker nodes
variable edge_count { default = "1"}    # load balancer nodes

# Run 'nova network-list' to get these names and values
# Floating ips are optional
variable external_network_uuid { default = "56e3d1ac-44d6-43d7-bea3-e2f334aa8f86" }
variable floating_ip_pool { default = "public-floating-601" }

# Run 'nova image-list' to get your image name
variable image_name  { default = "CentOS-7" }

#  Openstack flavors control the size of the instance, i.e. m1.xlarge.
#  Run 'nova flavor-list' to list the flavors in your environment
#  Below are typical settings for mantl
variable control_flavor_name { default = "CO2-Medium" }
variable worker_flavor_name { default = "CO2-Medium" }
variable edge_flavor_name { default = "Micro-Small" }

module "ssh-key" {
  source = "./terraform/openstack/keypair_v2"
  public_key = "${var.public_key}"
  keypair_name = "travis-ci-${var.build_number}-key"
}

#Create a network with an externally attached router
module "network" {
  source = "./terraform/openstack/network"
  external_net_uuid = "${var.external_network_uuid}"
  subnet_cidr = "${var.subnet_cidr}"
  name = "mantl-ci-${var.build_number}"
}


module "floating-ips-edge" {
  source = "./terraform/openstack/floating-ip"
  count = "${var.edge_count}"
  floating_pool = "${var.floating_ip_pool}"
}

# Create instances for each of the roles
module "instances-control" {
  source = "./terraform/openstack/instance"
  name = "travis-ci-${var.build_number}"
  count = "${var.control_count}"
  role = "control"
  volume_size = "50"
  network_uuid = "${module.network.network_uuid}"
  keypair_name = "${module.ssh-key.keypair_name}"
  flavor_name = "${var.control_flavor_name}"
  image_name = "${var.image_name}"
}

module "instances-worker" {
  source = "./terraform/openstack/instance"
  name = "travis-ci-${var.build_number}"
  count = "${var.worker_count}"
  volume_size = "100"
  count_format = "%03d"
  role = "worker"
  network_uuid = "${module.network.network_uuid}"
  keypair_name = "${module.ssh-key.keypair_name}"
  flavor_name = "${var.worker_flavor_name}"
  image_name = "${var.image_name}"
}

module "instances-edge" {
  source = "./terraform/openstack/instance"
  name = "travis-ci-${var.build_number}"
  count = "${var.edge_count}"
  volume_size = "20"
  count_format = "%02d"
  role = "edge"
  network_uuid = "${module.network.network_uuid}"
  floating_ips = "${module.floating-ips-edge.ip_list}"
  keypair_name = "${module.ssh-key.keypair_name}"
  flavor_name = "${var.edge_flavor_name}"
  image_name = "${var.image_name}"
}
