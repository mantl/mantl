variable "tectonic_config_version" {
  description = <<EOF
(internal) This declares the version of the global configuration variables.
It has no impact on generated assets but declares the version contract of the configuration.
EOF

  default = "1.0"
}

terraform {
  required_version = ">= 0.9.6"
}

variable "tectonic_container_images" {
  description = "(internal) Container images to use"
  type        = "map"

  default = {
    hyperkube                       = "quay.io/coreos/hyperkube:v1.6.2_coreos.0"
    pod_checkpointer                = "quay.io/coreos/pod-checkpointer:2cad4cac4186611a79de1969e3ea4924f02f459e"
    bootkube                        = "quay.io/coreos/bootkube:v0.4.2"
    console                         = "quay.io/coreos/tectonic-console:v1.5.6"
    identity                        = "quay.io/coreos/dex:v2.4.1"
    container_linux_update_operator = "quay.io/coreos/container-linux-update-operator:v0.2.0"
    kube_version_operator           = "quay.io/coreos/kube-version-operator:v1.6.2"
    tectonic_channel_operator       = "quay.io/coreos/tectonic-channel-operator:0.3.2"
    node_agent                      = "quay.io/coreos/node-agent:787844277099e8c10d617c3c807244fc9f873e46"
    prometheus_operator             = "quay.io/coreos/prometheus-operator:v0.9.1"
    tectonic_prometheus_operator    = "quay.io/coreos/tectonic-prometheus-operator:v1.2.0"
    node_exporter                   = "quay.io/prometheus/node-exporter:v0.14.0"
    kube_state_metrics              = "quay.io/coreos/kube-state-metrics:v0.5.0"
    config_reload                   = "quay.io/coreos/configmap-reload:v0.0.1"
    heapster                        = "gcr.io/google_containers/heapster:v1.3.0"
    addon_resizer                   = "gcr.io/google_containers/addon-resizer:1.7"
    stats_emitter                   = "quay.io/coreos/tectonic-stats:6e882361357fe4b773adbf279cddf48cb50164c1"
    stats_extender                  = "quay.io/coreos/tectonic-stats-extender:487b3da4e175da96dabfb44fba65cdb8b823db2e"
    error_server                    = "quay.io/coreos/tectonic-error-server:1.0"
    ingress_controller              = "gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.3"
    kubedns                         = "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.1"
    kubednsmasq                     = "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.1"
    kubedns_sidecar                 = "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.1"
    flannel                         = "quay.io/coreos/flannel:v0.7.1-amd64"
    etcd                            = "quay.io/coreos/etcd:v3.1.6"
    etcd_operator                   = "quay.io/coreos/etcd-operator:v0.2.5"
    kenc                            = "quay.io/coreos/kenc:48b6feceeee56c657ea9263f47b6ea091e8d3035"
    awscli                          = "quay.io/coreos/awscli:025a357f05242fdad6a81e8a6b520098aa65a600"
    kube_version                    = "quay.io/coreos/kube-version:0.1.0"
  }
}

variable "tectonic_versions" {
  description = "(internal) Versions of the components to use"
  type        = "map"

  default = {
    etcd       = "3.1.6"
    prometheus = "v1.6.3"
    monitoring = "1.2.0"
    kubernetes = "1.6.2+tectonic.1"
    tectonic   = "1.6.2-tectonic.1"
  }
}

variable "tectonic_service_cidr" {
  type    = "string"
  default = "10.3.0.0/16"

  description = "This declares the IP range to assign Kubernetes service cluster IPs in CIDR notation."
}

variable "tectonic_cluster_cidr" {
  type    = "string"
  default = "10.2.0.0/16"

  description = "This declares the IP range to assign Kubernetes pod IPs in CIDR notation."
}

variable "tectonic_master_count" {
  type    = "string"
  default = "1"

  description = <<EOF
The number of master nodes to be created.
This applies only to cloud platforms.
EOF
}

variable "tectonic_worker_count" {
  type    = "string"
  default = "3"

  description = <<EOF
The number of worker nodes to be created.
This applies only to cloud platforms.
EOF
}

variable "tectonic_etcd_count" {
  type    = "string"
  default = "0"

  description = <<EOF
The number of etcd nodes to be created.
If set to zero, the count of etcd nodes will be determined automatically.

Note: This is currently only supported on AWS.
EOF
}

variable "tectonic_etcd_servers" {
  description = <<EOF
(optional) List of external etcd v3 servers to connect with (hostnames/IPs only).
Needs to be set if using an external etcd cluster.

Example: `["etcd1", "etcd2", "etcd3"]`
EOF

  type    = "list"
  default = [""]
}

variable "tectonic_etcd_ca_cert_path" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The path of the file containing the CA certificate for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `tectonic_etcd_servers`, `tectonic_etcd_client_cert_path`, and `tectonic_etcd_client_key_path` must also be set.
EOF
}

variable "tectonic_etcd_client_cert_path" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The path of the file containing the client certificate for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `tectonic_etcd_servers`, `tectonic_etcd_ca_cert_path`, and `tectonic_etcd_client_key_path` must also be set.
EOF
}

variable "tectonic_etcd_client_key_path" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The path of the file containing the client key for TLS communication with etcd.

Note: This works only when used in conjunction with an external etcd cluster.
If set, the variables `tectonic_etcd_servers`, `tectonic_etcd_ca_cert_path`, and `tectonic_etcd_client_cert_path` must also be set.
EOF
}

variable "tectonic_base_domain" {
  type = "string"

  description = <<EOF
The base DNS domain of the cluster.

Example: `openstack.dev.coreos.systems`.

Note: This field MUST be set manually prior to creating the cluster.
This applies only to cloud platforms.
EOF
}

variable "tectonic_cluster_name" {
  type = "string"

  description = <<EOF
The name of the cluster.
If used in a cloud-environment, this will be prepended to `tectonic_base_domain` resulting in the URL to the Tectonic console.

Note: This field MUST be set manually prior to creating the cluster.
Warning: Special characters in the name like '.' may cause errors on OpenStack platforms due to resource name constraints.
EOF
}

variable "tectonic_pull_secret_path" {
  type    = "string"
  default = ""

  description = <<EOF
The path the pull secret file in JSON format.

Note: This field MUST be set manually prior to creating the cluster unless `tectonic_vanilla_k8s` is set to `true`.
EOF
}

variable "tectonic_license_path" {
  type    = "string"
  default = ""

  description = <<EOF
The path to the tectonic licence file.

Note: This field MUST be set manually prior to creating the cluster unless `tectonic_vanilla_k8s` is set to `true`.
EOF
}

variable "tectonic_cl_channel" {
  type    = "string"
  default = "stable"

  description = <<EOF
The Container Linux update channel.

Examples: `stable`, `beta`, `alpha`
EOF
}

variable "tectonic_update_server" {
  type        = "string"
  default     = "https://tectonic.update.core-os.net"
  description = "(internal) The URL of the Tectonic Omaha update server"
}

variable "tectonic_update_channel" {
  type        = "string"
  default     = "tectonic-1.6"
  description = "(internal) The Tectonic Omaha update channel"
}

variable "tectonic_update_app_id" {
  type        = "string"
  default     = "6bc7b986-4654-4a0f-94b3-84ce6feb1db4"
  description = "(internal) The Tectonic Omaha update App ID"
}

variable "tectonic_admin_email" {
  type = "string"

  description = <<EOF
The e-mail address used to login as the admin user to the Tectonic Console.

Note: This field MUST be set manually prior to creating the cluster.
EOF
}

variable "tectonic_admin_password_hash" {
  type = "string"

  description = <<EOF
The bcrypt hash of admin user password to login to the Tectonic Console.
Use the bcrypt-hash tool (https://github.com/coreos/bcrypt-tool/releases/tag/v1.0.0) to generate it.

Note: This field MUST be set manually prior to creating the cluster.
EOF
}

variable "tectonic_ca_cert" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The content of the PEM-encoded CA certificate, used to generate Tectonic Console's server certificate.
If left blank, a CA certificate will be automatically generated.
EOF
}

variable "tectonic_ca_key" {
  type    = "string"
  default = ""

  description = <<EOF
(optional) The content of the PEM-encoded CA key, used to generate Tectonic Console's server certificate.
This field is mandatory if `tectonic_ca_cert` is set.
EOF
}

variable "tectonic_ca_key_alg" {
  type    = "string"
  default = "RSA"

  description = <<EOF
(optional) The algorithm used to generate tectonic_ca_key.
The default value is currently recommend.
This field is mandatory if `tectonic_ca_cert` is set.
EOF
}

variable "tectonic_vanilla_k8s" {
  default = false

  description = <<EOF
If set to true, a vanilla Kubernetes cluster will be deployed, omitting any Tectonic assets.
EOF
}

variable "tectonic_experimental" {
  default = false

  description = <<EOF
If set to true, experimental Tectonic assets are being deployed.
EOF
}
