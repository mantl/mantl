# Download terraform.py, a dynamic Ansible inventory
resource "null_resource" "terraform-py" {
  provisioner "local-exec" {
    command = "curl -sLo plugins/inventory/terraform.py https://raw.githubusercontent.com/mantl/terraform.py/master/terraform.py"
  }

  provisioner "local-exec" {
    command = "chmod +x plugins/inventory/terraform.py"
  }
}
