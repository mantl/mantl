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
  edge_count = 2
  ssh_user = ""
  ssh_key = ""
  consul_dc = ""

  #Optional Parameters
  #linked_clone = ""
  #folder = ""  
  #control_cpu = ""
  #worker_cpu = ""
  #edge_cpu = ""
  #control_ram = ""
  #worker_ram = ""
  #edge_ram = ""
}
