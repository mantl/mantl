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
