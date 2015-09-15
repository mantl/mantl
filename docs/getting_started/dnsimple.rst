DNSimple
=========

Terraform can use DNSimple to provide DNS records for your cluster, independent of which
provider you use to provision your servers. For configuration examples, look
at the ``*.sample.tf`` files in the ``terraform/`` directory, which show how
you can hook up a server provider's instances to DNSimple.

DNSimple will provide these A-type records:

- ``[short-name]-control-[nn].[domain]``
- ``[short-name]-worker-[nnn].[domain]``
- ``*.[short-name]-lb.[domain]``

For example, with ``short-name=mi`` and ``domain=example.com``, 3 control
nodes and 4 worker nodes, that will give us these DNS records:

- ``mi-control-01.example.com``
- ``mi-control-02.example.com``
- ``mi-control-03.example.com``
- ``mi-worker-001.example.com``
- ``mi-worker-002.example.com``
- ``mi-worker-003.example.com``
- ``mi-worker-004.example.com``
- ``mi-lb.example.com`` (pointing to worker 1)
- ``mi-lb.example.com`` (pointing to worker 2)
- ``mi-lb.example.com`` (pointing to worker 3)
- ``mi-lb.example.com`` (pointing to worker 4)

The control- and worker records are intented to be used to access
the nodes directly, e.g. via your browser. You can then reach the
Marathon control panel at `http://mi-control-01.example.com:8080/
<http://mi-control-01.example.com:8080/>`_.

The lb records are intended to reach your load balancers that run
on every worker node. That makes it easy to access your load-balanced
applications from the browser, for example `http://myapp.mi-lb.example.com/
<http://myapp.mi-lb.example.com/>`_. For this to work, you will have to
configure ansible to setup the correct domain for haproxy as well. Look
at ``terraform.sample.yml`` for hints.

Beware that in a dynamic environment, where worker nodes are being brought
up and taken down frequently, it's not a good idea to point traffic direcly
to the LB URLs - because of DNS caching. If a DNS record changes, it can
take a while for the change to propagate to all the clients. Your best bet
for frontend applications is to route traffic to them via user-facing
load balancers that seldom change IP addresses or are shut down/restarted.

DNSimple Username/Token
^^^^^^^^^^^^^^^^^^^^^^^

The easiest way to configure credentials for DNSimple is by setting
environment variables:

.. envvar:: DNSIMPLE_EMAIL

   Your e-mail address for the DNSimple account

.. envvar:: DNSIMPLE_TOKEN

   The DNSimple token (found in the DNSimple admin panel)

Alternatively, you can set up the DNSimple provider credentials in your .tf
file:

.. code-block:: shell
  provider "dnsimple" {
    token = "your dnsimple token"
    email = "your e-mail address for the dnsimple account"
  }

