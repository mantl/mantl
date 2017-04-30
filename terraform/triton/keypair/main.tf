# input variables
variable short_name { default = "mantl" }
variable public_key_material { }

resource "triton_key" "key" {
  name = "${var.short_name}"
  key = "${var.public_key_material}"
}
