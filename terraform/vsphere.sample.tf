provider "vsphere" {
  vsphere_server = ""
  user = ""
  password = ""
  allow_unverified_ssl = "false"
}

module "vsphere-dc" {
  source = "./terraform/vsphere"
  long_name = ""
  short_name = ""
  datacenter = ""
  cluster = ""
  pool = "" # format is cluster_name/Resources/pool_name
  template = ""
  network_label = ""
  domain = ""
  dns_server1 = ""
  dns_server2 = ""
  datastore = ""
  control_count = 3
  worker_count = 4
  edge_count = 2
  kubeworker_count = 0
  control_volume_size = 20 # size in gigabytes
  worker_volume_size = 20
  edge_volume_size = 20
  ssh_user = ""
  ssh_key = ""
  consul_dc = ""

  #Optional Parameters
  #folder = ""  
  #control_cpu = ""
  #worker_cpu = ""
  #edge_cpu = ""
  #control_ram = ""
  #worker_ram = ""
  #edge_ram = ""
  #disk_type = "" # thin or eager_zeored, default is thin
  #linked_clone = "" # true or false, default is false.  If using linked_clones and have problems installing Mantl, revert to full clones 
}
