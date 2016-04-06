variable "datacenter" {}
variable "cluster" {}
variable "pool" {}
variable "template" {}
variable "ssh_user" {}
variable "ssh_key" {}
variable "consul_dc" {}
variable "datastore" {}
variable "disk_type" { default = "thin" } 
variable "network_label" {}

variable "short_name" {default = "mantl"}
variable "long_name" {default = "mantl"}

variable "folder" {default = ""}
variable "control_count" {default = 3}
variable "worker_count" {default = 2}
variable "kube_worker_count" {default = 0}
variable "edge_count" {default = 2}
variable "control_volume_size" {default = 20}
variable "worker_volume_size" {default = 20}
variable "edge_volume_size" {default = 20}
variable "control_cpu" { default = 1 }
variable "worker_cpu" { default = 1 }
variable "edge_cpu" { default = 1 }
variable "control_ram" { default = 4096 }
variable "worker_ram" { default = 4096 }
variable "edge_ram" { default = 4096 }

resource "vsphere_virtual_machine" "mi-control-nodes" {
  name = "${var.short_name}-control-${format("%02d", count.index+1)}"
  datacenter = "${var.datacenter}"
  folder = "${var.folder}"
  cluster = "${var.cluster}"
  resource_pool = "${var.pool}"

  vcpu = "${var.control_cpu}"
  memory = "${var.control_ram}"

  disk {
    size = "${var.control_volume_size}"
    template = "${var.template}"
    type = "${var.disk_type}"
    datastore = "${var.datastore}"
  }

  network_interface {
    label = "${var.network_label}"
  }

  custom_configuration_parameters = {
    role = "control"
    ssh_user = "${var.ssh_user}"
    consul_dc = "${var.consul_dc}"
  }

  connection = {
      user = "${var.ssh_user}"
      key_file = "${var.ssh_key}"
      host = "${self.network_interface.0.ipv4_address}"
  }

  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
  }

  count = "${var.control_count}"
}

resource "vsphere_virtual_machine" "mi-worker-nodes" {
  name = "${var.short_name}-worker-${format("%03d", count.index+1)}"
  datacenter = "${var.datacenter}"
  folder = "${var.folder}"
  cluster = "${var.cluster}"
  resource_pool = "${var.pool}"

  vcpu = "${var.worker_cpu}"
  memory = "${var.worker_ram}"

  disk {
    size = "${var.worker_volume_size}"
    template = "${var.template}"
    type = "${var.disk_type}"
    datastore = "${var.datastore}"
  }

  network_interface {
    label = "${var.network_label}"
  }

  custom_configuration_parameters = {
    role = "worker"
    ssh_user = "${var.ssh_user}"
    consul_dc = "${var.consul_dc}"
  }

  connection = {
      user = "${var.ssh_user}"
      key_file = "${var.ssh_key}"
      host = "${self.network_interface.0.ipv4_address}"
  }

  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
  }

  count = "${var.worker_count}"
}

resource "vsphere_virtual_machine" "mi-kube-worker-nodes" {
  name = "${var.short_name}-kube-worker-${format("%03d", count.index+1)}"
  image = "${var.template}"

  datacenter = "${var.datacenter}"
  host = "${var.host}"
  resource_pool = "${var.pool}"

  cpus = "${var.worker_cpu}"
  memory = "${var.worker_ram}"

  configuration_parameters = {
    role = "kubeworker"
    ssh_user = "${var.ssh_user}"
    consul_dc = "${var.consul_dc}"
  }

  connection = {
      user = "${var.ssh_user}"
      key_file = "${var.ssh_key}"
      host = "${self.ip_address}"
  }

  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
  }

  count = "${var.kube_worker_count}"
}

resource "vsphere_virtual_machine" "mi-edge-nodes" {
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}"
  image = "${var.template}"

  datacenter = "${var.datacenter}"
  host = "${var.host}"
  resource_pool = "${var.pool}"

  cpus = "${var.worker_cpu}"
  memory = "${var.worker_ram}"

  configuration_parameters = {
    role = "kubeworker"
    ssh_user = "${var.ssh_user}"
    consul_dc = "${var.consul_dc}"
  }

  connection = {
      user = "${var.ssh_user}"
      key_file = "${var.ssh_key}"
      host = "${self.ip_address}"
  }

  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
  }

  count = "${var.kube_worker_count}"
}

resource "vsphere_virtual_machine" "mi-edge-nodes" {
  name = "${var.short_name}-edge-${format("%02d", count.index+1)}"
  datacenter = "${var.datacenter}"
  folder = "${var.folder}"
  cluster = "${var.cluster}"
  resource_pool = "${var.pool}"

  vcpu = "${var.edge_cpu}"
  memory = "${var.edge_ram}"

  disk {
    size = "${var.edge_volume_size}"
    template = "${var.template}"
    type = "${var.disk_type}"
    datastore = "${var.datastore}"
  }

  network_interface {
    label = "${var.network_label}"
  }

  custom_configuration_parameters = {
    role = "edge"
    ssh_user = "${var.ssh_user}"
    consul_dc = "${var.consul_dc}"
  }

  connection = {
    user = "${var.ssh_user}"
    key_file = "${var.ssh_key}"
    host = "${self.network_interface.0.ipv4_address}"
  }

  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl --static set-hostname ${self.name}" ]
  }

  count = "${var.edge_count}"
}

output "control_ips" {
  value = "${join(\",\", vsphere_virtual_machine.mi-control-nodes.*.network_interface.0.ipv4_address)}"
}

output "worker_ips" {
  value = "${join(\",\", vsphere_virtual_machine.mi-worker-nodes.*.network_interface.0.ipv4_address)}"
}

output "kube_worker_ips" {
  value = "${join(\",\", vsphere_virtual_machine.mi-kube-worker-nodes.*.network_interface.ip_address)}"
}

output "kube_worker_ips" {
  value = "${join(\",\", vsphere_virtual_machine.mi-kube-worker-nodes.*.network_interface.ip_address)}"
}

output "edge_ips" {
  value = "${join(\",\", vsphere_virtual_machine.mi-edge-nodes.*.network_interface.0.ipv4_address)}"
}
