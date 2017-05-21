module "bootkube" {
  source         = "../../modules/bootkube"
  cloud_provider = ""

  # Address of kube-apiserver
  kube_apiserver_url = "https://${var.tectonic_metal_controller_domain}:443"

  # Address of Identity service
  oidc_issuer_url = "https://${var.tectonic_metal_ingress_domain}/identity"

  # platform-independent defaults
  container_images = "${var.tectonic_container_images}"

  ca_cert    = "${var.tectonic_ca_cert}"
  ca_key     = "${var.tectonic_ca_key}"
  ca_key_alg = "${var.tectonic_ca_key_alg}"

  service_cidr = "${var.tectonic_service_cidr}"
  cluster_cidr = "${var.tectonic_cluster_cidr}"

  advertise_address = "0.0.0.0"
  anonymous_auth    = "false"

  oidc_username_claim = "email"
  oidc_groups_claim   = "groups"
  oidc_client_id      = "tectonic-kubectl"

  etcd_endpoints       = ["${split(",", length(var.tectonic_etcd_servers) == 0 ? "127.0.0.1" : join(",", var.tectonic_etcd_servers))}"]
  etcd_ca_cert         = "${var.tectonic_etcd_ca_cert_path}"
  etcd_client_cert     = "${var.tectonic_etcd_client_cert_path}"
  etcd_client_key      = "${var.tectonic_etcd_client_key_path}"
  experimental_enabled = "${var.tectonic_experimental}"
}

module "tectonic" {
  source   = "../../modules/tectonic"
  platform = ""

  # Address of kube-apiserver
  kube_apiserver_url = "https://${var.tectonic_metal_controller_domain}:443"

  # Address of the Tectonic console (without protocol)
  base_address = "${var.tectonic_metal_ingress_domain}"

  container_images = "${var.tectonic_container_images}"
  versions         = "${var.tectonic_versions}"

  license_path     = "${var.tectonic_vanilla_k8s ? "/dev/null" : pathexpand(var.tectonic_license_path)}"
  pull_secret_path = "${var.tectonic_vanilla_k8s ? "/dev/null" : pathexpand(var.tectonic_pull_secret_path)}"

  admin_email         = "${var.tectonic_admin_email}"
  admin_password_hash = "${var.tectonic_admin_password_hash}"

  update_channel = "${var.tectonic_update_channel}"
  update_app_id  = "${var.tectonic_update_app_id}"
  update_server  = "${var.tectonic_update_server}"

  ca_generated = "${module.bootkube.ca_cert == "" ? false : true}"
  ca_cert      = "${module.bootkube.ca_cert}"
  ca_key_alg   = "${module.bootkube.ca_key_alg}"
  ca_key       = "${module.bootkube.ca_key}"

  console_client_id = "tectonic-console"
  kubectl_client_id = "tectonic-kubectl"
  ingress_kind      = "HostPort"
  experimental      = "${var.tectonic_experimental}"
  master_count      = "${length(var.tectonic_metal_controller_names)}"
}

data "archive_file" "assets" {
  type       = "zip"
  source_dir = "${path.cwd}/generated/"

  # Because the archive_file provider is a data source, depends_on can't be
  # used to guarantee that the tectonic/bootkube modules have generated
  # all the assets on disk before trying to archive them. Instead, we use their
  # ID outputs, that are only computed once the assets have actually been
  # written to disk. We re-hash the IDs to make the filename shorter, since
  # there is no security nor collision risk anyways.
  #
  # Additionally, data sources do not support managing any lifecycle whatsoever,
  # and therefore, the archive is never deleted. To avoid cluttering the module
  # folder, we write it in the TerraForm managed hidden folder `.terraform`.
  output_path = "${path.cwd}/.terraform/generated_${sha1("${module.tectonic.id} ${module.bootkube.id}")}.zip"
}
