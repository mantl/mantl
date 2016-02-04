DNS
===

.. versionadded:: 0.3

Terraform lets you configure DNS for your instances. The DNS provider is loosely
coupled from the server provider, so you could for example use the dnsimple
provider for either OpenStack or AWS hosts, or use the Google Cloud DNS provider
for DigitalOcean hosts.

Providers
---------

These are the supported DNS providers:

.. toctree::
   :maxdepth: 1

   cloudflare.rst
   dnsimple.rst
   clouddns.rst
   route53.rst

DNS Records and Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The providers create a uniform set of DNS A records:

- ``{short-name}-control-{nn}.node{subdomain}.{domain}``
- ``{short-name}-edge-{nn}.node{subdomain}.{domain}``
- ``{short-name}-worker-{nnn}.node{subdomain}.{domain}``
- ``{control}{subdomain}.{domain}``
- ``*.{subdomain}.{domain}``

For example, with ``short-name=mantl``, ``domain=example.com``, a blank
subdomain, 3 control nodes, 4 worker nodes, and 2 edge nodes, that will give us
these DNS records:

- ``mantl-control-01.node.example.com``
- ``mantl-control-02.node.example.com``
- ``mantl-control-03.node.example.com``
- ``mantl-worker-001.node.example.com``
- ``mantl-worker-002.node.example.com``
- ``mantl-worker-003.node.example.com``
- ``mantl-worker-004.node.example.com``
- ``mantl-edge-01.node.example.com``
- ``mantl-edge-02.node.example.com``
- ``control.example.com`` (pointing to control 1)
- ``control.example.com`` (pointing to control 2)
- ``control.example.com`` (pointing to control 3)
- ``*.example.com`` (pointing to edge node load balancer)

If you don't want the DNS records hanging off the apex, you can specify the
``subdomain`` parameter to the DNS providers, which will be inserted in the
records just before the apex. For example, if ``subdomain=.mantl`` in the
previous config, the wildcard records would be ``*.mantl.example.com``.

.. warning::
   Due to a limitation in Terraform's string support, the subdomain *must* begin
   with a period (for example ``.mantl``).

The node records are intended to be used to access each node individually for
maintenance. You can access the frontend web components of the Mantl cluster
through ``control.example.com``, which will direct you to the rest of the stack.

You can use the wildcard records for load-balanced access to any app in
Marathon. For example, if you have an app named ``test`` running in Marathon,
you can access it at ``test.example.com``. Please see the
:doc:`../components/traefik` configuration for more details.

Configuration
^^^^^^^^^^^^^

A good way to configure DNS is to move the values common to your cloud config
and DNS config into separate variables. You can do that like this:

.. code-block:: javascript

    variable control_count { default = 3 }
    variable worker_count { default = 2 }
    variable edge_count { default = 2 }
    variable short_name { default = "mantl" }

Then use those variables in the module like this:

.. code-block:: javascript

    module "dns" {
      source = "./terraform/cloudflare"

      control_count = "${var.control_count}"
      control_ips = "${module.do-hosts.control_ips}"
      domain = "mantl.io"
      edge_count = "${var.edge_count}"
      edge_ips = "${module.do-hosts.edge_ips}"
      short_name = "${var.short_name}"
      subdomain = ".do.test"
      worker_count = "${var.worker_count}"
      worker_ips = "${module.do-hosts.worker_ips}"
    }

Configuration Variables
^^^^^^^^^^^^^^^^^^^^^^^

Configuration is done with a set of consistent variables across the providers:

.. data:: control_count, worker_count, and edge_count

   The count of control servers

.. data:: control_ips, worker_ips, and edge_ips

   A comma-separated list of IPs. The cloud provider modules all export this as
   ``control_ips``, ``worker_ips``, and ``edge_ips`` as well, so you can plug it
   in like so:

   .. code-block:: javascript

      control_ips = "${module.your-hosts.control_ips}"

.. data:: domain

   The top level domain to add the records to.

   Example: ``mantl.io``

.. data:: short_name

   The same short name passed into the cloud provider, used to generate
   consistent names.

.. data:: subdomain

   A path to put between the top-level domain and the generated records. *Must*
   begin with a period.

   Example: ``.apps``

.. data:: control_subdomain

   The name for the control group (to generate ``control.yourdomain.com``.) By
   default, this is ``control``, but you can change it to whatever you'd like.
