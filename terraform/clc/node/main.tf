# defines a publicly accessible server 

# input variables
variable role {}
variable count {}
variable group_id {}
variable location { default = "CA1" }
variable image_name { default = "CENTOS-7-64-TEMPLATE" }
variable server_type { default = "standard" }
variable cpu { default = 2 }
variable mem { default = 4096 }

variable ssh_pass {}
variable ssh_user { default = "root" }
variable ssh_key { default = "~/.ssh/id_rsa.pub" }


resource "clc_server" "node" {
  count = "${var.count}"
  group_id = "${var.group_id}"
  name_template = "-${var.role}"
  source_server_id = "${var.image_name}"
  cpu = "${var.cpu}"
  memory_mb = "${var.mem}"
  type = "${var.server_type}"
  password = "${var.ssh_pass}"

  metadata {
    dc = "${var.location}"
    role = "${var.role}"
  }  
}


resource "clc_public_ip" "ip" {
  count = "${var.count}"
  server_id = "${element(clc_server.node.*.id, count.index)}"
  internal_ip_address = "${element(clc_server.node.*.private_ip_address, count.index)}"
  ports
    {
      protocol = "TCP"
      port = 22
    }
  ports
    {
      protocol = "TCP"
      port = 80
    }
  ports
    {
      protocol = "TCP"
      port = 443
    }
  connection {
    host = "${self.id}"
    user = "${var.ssh_user}"
    password = "${var.ssh_pass}"
  }
  provisioner "remote-exec" {
    inline = [ "mkdir ~/.ssh" ]
  }
  provisioner "file" {
    source = "${var.ssh_key}"
    destination = "/root/.ssh/authorized_keys"
  }
  provisioner "remote-exec" {
    inline = [ "yum remove -y open-vm-tools" ]
  }
}

output "server_id" {
  value = "${join(\",\", clc_server.node.*.id)}"
}
output "private_ip" {
  value = "${join(\",\", clc_server.node.*.private_ip_address)}"
}
output "public_ip" {
  value = "${join(\",\", clc_server.node.*.public_ip_address)}"
}
