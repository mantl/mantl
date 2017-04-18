# input variables
variable count { }
variable image { }
variable keys { }
variable package { }
variable private_network { }
variable public_network { }
variable role { }
variable short_name { }

resource "triton_machine" "instance" {
  name = "${var.short_name}-${var.role}-${format("%02d", count.index+1)}"
  package = "${var.package}"
  image = "${var.image}"
  root_authorized_keys = "${var.keys}"

  tags {
    role = "${var.role}"
  }

  count = "${var.count}"

  networks = [
    "${var.public_network}",
    "${var.private_network}"
  ]
}

output "ips" {
  value = "${join(",", triton_machine.instance.*.primaryip)}"
}
