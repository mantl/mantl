resource "null_resource" "kubeconfig" {
  count = "${length(var.tectonic_metal_controller_domains) + length(var.tectonic_metal_worker_domains)}"

  connection {
    type    = "ssh"
    host    = "${element(concat(var.tectonic_metal_controller_domains, var.tectonic_metal_worker_domains), count.index)}"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    content     = "${module.bootkube.kubeconfig}"
    destination = "$HOME/kubeconfig"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/core/kubeconfig /etc/kubernetes/kubeconfig",
    ]
  }
}

resource "null_resource" "bootstrap" {
  # Without depends_on, this remote-exec may start before the kubeconfig copy.
  # Terraform only does one task at a time, so it would try to bootstrap
  # Kubernetes and Tectonic while no Kubelets are running. Ensure all nodes
  # receive a kubeconfig before proceeding with bootkube and tectonic.
  depends_on = ["null_resource.kubeconfig"]

  connection {
    type    = "ssh"
    host    = "${element(var.tectonic_metal_controller_domains, 0)}"
    user    = "core"
    timeout = "60m"
  }

  provisioner "file" {
    source      = "${path.cwd}/generated"
    destination = "$HOME/tectonic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt",
      "sudo rm -rf /opt/tectonic",
      "sudo mv /home/core/tectonic /opt/",
      "sudo systemctl start ${var.tectonic_vanilla_k8s ? "bootkube" : "tectonic"}",
    ]
  }
}
