variable subnet_cidr { default = "10.0.0.0/24" }
variable public_key { default = "/home/you/.ssh/id_rsa.pub" }

variable name { default = "mantl" }     # resources will start with "mantl-"
variable control_count { default = "3"} # mesos masters, zk leaders, consul servers
variable worker_count { default = "5"}  # worker nodes
variable edge_count { default = "2"}    # load balancer nodes

# Run 'nova network-list' to get these names and values
# Floating ips are optional
variable external_network_uuid { default = "uuid-of-your-external-network" }
variable floating_ip_pool { default = "name-of-your-floating-ip-pool" }

# Run 'nova image-list' to get your image name
variable image_name  { default = "your-CentOS-7" }

#  Openstack flavors control the size of the instance, i.e. m1.xlarge.
#  Run 'nova flavor-list' to list the flavors in your environment
#  Below are typical settings for mantl
variable control_flavor_name { default = "your-XLarge" }
variable worker_flavor_name { default = "your-Large" }
variable edge_flavor_name { default = "your-Small" }

module "ssh-key" {
  source = "./terraform/openstack/keypair_v2"
  public_key = "${var.public_key}"
  keypair_name = "mantl-key"
}

#Create a network with an externally attached router
module "network" {
  source = "./terraform/openstack/network"
  external_net_uuid = "${var.external_network_uuid}"
  subnet_cidr = "${var.subnet_cidr}"
}

# Create floating IPs for each of the roles
# These are not required if your network is exposed to the internet
# or you don't want floating ips for the instances.
module "floating-ips-control" {
  source = "./terraform/openstack/floating-ip"
  count = "${var.control_count}"
  floating_pool = "${var.floating_ip_pool}"
}

module "floating-ips-worker" {
  source = "./terraform/openstack/floating-ip"
  count = "${var.worker_count}"
  floating_pool = "${var.floating_ip_pool}"
}

module "floating-ips-edge" {
  source = "./terraform/openstack/floating-ip"
  count = "${var.edge_count}"
  floating_pool = "${var.floating_ip_pool}"
}

# Create instances for each of the roles
module "instances-control" {
  source = "./terraform/openstack/instance"
  name = "${var.name}"
  count = "${var.control_count}"
  role = "control"
  volume_size = "50"
  network_uuid = "${module.network.network_uuid}"
  floating_ips = "${module.floating-ips-control.ip_list}"
  keypair_name = "${module.ssh-key.keypair_name}"
  flavor_name = "${var.control_flavor_name}"
  image_name = "${var.image_name}"
}

module "instances-worker" {
  source = "./terraform/openstack/instance"
  name = "${var.name}"
  count = "${var.worker_count}"
  volume_size = "100"
  count_format = "%03d"
  role = "worker"
  network_uuid = "${module.network.network_uuid}"
  floating_ips = "${module.floating-ips-worker.ip_list}"
  keypair_name = "${module.ssh-key.keypair_name}"
  flavor_name = "${var.worker_flavor_name}"
  image_name = "${var.image_name}"
}

module "instances-edge" {
  source = "./terraform/openstack/instance"
  name = "${var.name}"
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

