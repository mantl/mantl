// CoreOS Install Profile
resource "matchbox_profile" "coreos-install" {
  name   = "coreos-install"
  kernel = "/assets/coreos/${var.tectonic_metal_cl_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.tectonic_metal_cl_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "coreos.config.url=${var.tectonic_metal_matchbox_http_url}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${file("${path.module}/cl/coreos-install.yaml.tmpl")}"
}

// Self-hosted Kubernetes Controller profile
resource "matchbox_profile" "tectonic-controller" {
  name                   = "tectonic-controller"
  container_linux_config = "${file("${path.module}/cl/bootkube-controller.yaml.tmpl")}"
}

// Self-hosted Kubernetes Worker profile
resource "matchbox_profile" "tectonic-worker" {
  name                   = "tectonic-worker"
  container_linux_config = "${file("${path.module}/cl/bootkube-worker.yaml.tmpl")}"
}
