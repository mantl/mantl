DNSimple
=========

.. versionadded:: 0.3

Terraform can use DNSimple to provide DNS records for your cluster, independent
of which provider you use to provision your servers.

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

