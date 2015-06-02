# input variables
variable short_name { default = "mi" }
variable public_key { default = "${file("~/.ssh/id_rsa.pub")}"}

# create resources
resource "digitalocean_ssh_key" "default" {
  name = "${vars.short_name}-key"
  public_key = "${vars.public_key}"
}

# output variables
output "keypair_id" {
  "${digitalocean_ssh_key.default.id}"
}
