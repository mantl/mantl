data "aws_region" "current" {
  current = true
}

resource "aws_s3_bucket" "tectonic" {
  # Buckets must start with a lower case name and are limited to 63 characters,
  # so we prepende the letter 'a' and use the md5 hex digest for the case of a long domain
  # leaving 29 chars for the cluster name.
  bucket = "a${var.tectonic_cluster_name}-${md5("${data.aws_region.current.name}-${var.tectonic_base_domain}")}"

  acl = "private"
}

# Bootkube / Tectonic assets
resource "aws_s3_bucket_object" "tectonic-assets" {
  bucket = "${aws_s3_bucket.tectonic.bucket}"
  key    = "assets.zip"
  source = "${data.archive_file.assets.output_path}"
  acl    = "private"

  # To be on par with the current Tectonic installer, we only do server-side
  # encryption, using AES256. Eventually, we should start using KMS-based
  # client-side encryption.
  server_side_encryption = "AES256"
}

# kubeconfig
resource "aws_s3_bucket_object" "kubeconfig" {
  bucket  = "${aws_s3_bucket.tectonic.bucket}"
  key     = "kubeconfig"
  content = "${module.bootkube.kubeconfig}"
  acl     = "private"

  # The current Tectonic installer stores bits of the kubeconfig in KMS. As we
  # do not support KMS yet, we at least offload it to S3 for now. Eventually,
  # we should consider using KMS-based client-side encryption, or uploading it
  # to KMS.
  server_side_encryption = "AES256"
}
