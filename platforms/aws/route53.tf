data "aws_route53_zone" "tectonic-ext" {
  count = "${var.tectonic_aws_external_vpc_public}"
  name  = "${var.tectonic_base_domain}"
}

resource "aws_route53_zone" "tectonic-int" {
  count         = "${var.tectonic_aws_external_private_zone == "" ? 1 : 0}"
  vpc_id        = "${module.vpc.vpc_id}"
  name          = "${var.tectonic_base_domain}"
  force_destroy = true

  tags = "${merge(map(
      "Name", "${var.tectonic_cluster_name}_tectonic_int_zone",
      "KubernetesCluster", "${var.tectonic_cluster_name}"
    ), var.tectonic_aws_extra_tags)}"
}
