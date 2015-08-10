provider "vsphere" {
  vcenter_server = ""
  user = ""
  password = ""
  insecure_connection = ""
}

module "vsphere-dc" {
  source = "./terraform/vsphere"
  long_name = ""
  short_name = ""
  datacenter = ""
  host = ""
  pool = ""
  template = ""
  control_count = 3
  worker_count = 3
  ssh_user = ""
  ssh_key = ""
  consul_dc = ""
}
