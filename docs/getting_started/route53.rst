Route53
=======

Terraform can use ``aws_route53_record`` resources to provide DNS records for
your cluster.

In addition to the :doc:`normal DNS variables <dns>`, you will need to specify
the ``hosted_zone_id`` parameter. You can find your own hosted zone ID in your
AWS Route 53 console.

.. image:: /_static/aws_route53_zone_id.png
   :alt: AWS Route53 Hosted Zone Id example

Route53 uses your normal :doc:`aws` provider credentials.

.. code-block:: json

  # Example setup for an AWS Route53
  module "route53" {
    source = "./terraform/aws/route53/dns"
    control_count = "${var.control_count}"
    control_ips = "${module.control-nodes.ec2_ips}"
    domain = "my-domain.com"
    edge_count = "${var.edge_count}"
    edge_ips = "${module.edge-nodes.ec2_ips}"
    hosted_zone_id = "XXXXXXXXXXXX"
    short_name = "${var.short_name}"
    subdomain = ".dev"
    worker_count = "${var.worker_count}"
    worker_ips = "${module.worker-nodes.ec2_ips}"
    kubeworker_count = "${var.kubeworker_count}"
    kubeworker_ips = "${module.kubeworker-nodes.ec2_ips}"
  }
