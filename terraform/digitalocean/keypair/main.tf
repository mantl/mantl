# input variables
variable short_name { default = "mi" }
variable public_key_filename { default = "~/.ssh/id_rsa.pub" }

# create resources
resource "digitalocean_ssh_key" "default" {
  name = "${var.short_name}-key"
  public_key = "${file(var.public_key_filename)}"
}

# output variables
output "keypair_id" {
  value = "${digitalocean_ssh_key.default.id}"
}
