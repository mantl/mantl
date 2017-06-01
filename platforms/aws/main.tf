module "resource_group" {
  source = "../../modules/azure/resource-group"

  external_rsg_name       = "${var.tectonic_azure_external_rsg_name}"
  tectonic_azure_location = "${var.tectonic_azure_location}"
  tectonic_cluster_name   = "${var.tectonic_cluster_name}"
}

module "vnet" {
  source = "../../modules/azure/vnet"

  location                  = "${var.tectonic_azure_location}"
  resource_group_name       = "${module.resource_group.name}"
  tectonic_cluster_name     = "${var.tectonic_cluster_name}"
  vnet_cidr_block           = "${var.tectonic_azure_vnet_cidr_block}"
  external_vnet_name        = "${var.tectonic_azure_external_vnet_name}"
  external_master_subnet_id = "${var.tectonic_azure_external_master_subnet_id}"
  external_worker_subnet_id = "${var.tectonic_azure_external_worker_subnet_id}"
}

module "etcd" {
  source = "../../modules/azure/etcd"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_etcd_vm_size}"

  etcd_count      = "${var.tectonic_etcd_count}"
  base_domain     = "${var.tectonic_base_domain}"
  cluster_name    = "${var.tectonic_cluster_name}"
  public_ssh_key  = "${var.tectonic_azure_ssh_key}"
  virtual_network = "${module.vnet.vnet_id}"
  subnet          = "${module.vnet.master_subnet}"
}

module "masters" {
  source = "../../modules/azure/master"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_master_vm_size}"

  master_count                 = "${var.tectonic_master_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_id}"
  subnet                       = "${module.vnet.master_subnet}"
  kube_image_url               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_kube_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/master"
  kubelet_node_taints          = "node-role.kubernetes.io/master=:NoSchedule"
  bootkube_service             = "${module.bootkube.systemd_service}"
  tectonic_service             = "${module.tectonic.systemd_service}"
  tectonic_service_disabled    = "${var.tectonic_vanilla_k8s}"

  use_custom_fqdn = "${var.tectonic_azure_use_custom_fqdn}"
}

module "workers" {
  source = "../../modules/azure/worker"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${module.resource_group.name}"
  image_reference     = "${var.tectonic_azure_image_reference}"
  vm_size             = "${var.tectonic_azure_worker_vm_size}"

  worker_count                 = "${var.tectonic_worker_count}"
  base_domain                  = "${var.tectonic_base_domain}"
  cluster_name                 = "${var.tectonic_cluster_name}"
  public_ssh_key               = "${var.tectonic_azure_ssh_key}"
  virtual_network              = "${module.vnet.vnet_id}"
  subnet                       = "${module.vnet.worker_subnet}"
  kube_image_url               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 0)}"
  kube_image_tag               = "${element(split(":", var.tectonic_container_images["hyperkube"]), 1)}"
  kubeconfig_content           = "${module.bootkube.kubeconfig}"
  tectonic_kube_dns_service_ip = "${module.bootkube.kube_dns_service_ip}"
  cloud_provider               = ""
  kubelet_node_label           = "node-role.kubernetes.io/node"
}

module "dns" {
  source = "../../modules/azure/dns"

  master_ip_addresses = "${module.masters.ip_address}"
  console_ip_address  = "${module.masters.console_ip_address}"
  etcd_ip_addresses   = "${module.etcd.ip_address}"

  base_domain  = "${var.tectonic_base_domain}"
  cluster_name = "${var.tectonic_cluster_name}"

  location            = "${var.tectonic_azure_location}"
  resource_group_name = "${var.tectonic_azure_dns_resource_group}"

  use_custom_fqdn = "${var.tectonic_azure_use_custom_fqdn}"

  // TODO etcd list
  // TODO worker list
}
