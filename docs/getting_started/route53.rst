Route53
=======

Terraform can use aws_route53_record resources to provide DNS records for 
your cluster.  For configuration examples, check the following section in 
``aws.sample.tf`` file in the ``terraform/`` directory, which show how you 
can hook up a server provider's instances to Route53.

.. code-block:: javascript

   module "route53-dns" {
     source = "./terraform/route53/dns"
     short_name = "mi"
     control_count = 3
     worker_count = 3
     domain = "example.com"
     hosted_zone_id = "XXXXXXXXX"
     control_ips = "${module.aws-dc.control_ips}"
     worker_ips = "${module.aws-dc.worker_ips}"
   }

You can find your hosted_zone_id in your aws route53 console as follow.

.. image:: /_static/aws_route53_zone_id.png
   :alt: AWS Route53 Hosted Zone Id example

The same as DNSimple, Route53 will provide these A-type records:

- ``[short-name]-control-[nn].[domain]``
- ``[short-name]-worker-[nnn].[domain]``
- ``*.[short-name]-lb.[domain]``
