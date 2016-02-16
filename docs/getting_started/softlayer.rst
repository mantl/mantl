SoftLayer
=========

.. versionadded:: 0.3.3

As of Mantl 0.3.3 you can bring up SoftLayer
servers using Terraform. Mantl uses Terraform to
provision hosts.

As of now, the released version of Terraform doesn't have SoftLayer support,
but one can build a `custom binary with SoftLayer provisioning.<https://github.com/hashicorp/terraform/pull/2554>`.

Configuring Terraform for SoftLayer
-----------------------------------

Before we can build any servers using Terraform and Ansible, we need to
configure authentication. We'll be filling in the authentication variables for
the template located at ``terraform/softlayer.sample.tf``. It looks like this:

.. this is highlighted as javascript for convenience, but obviously that's not
   the *real* language.
.. literalinclude:: ../../terraform/softlayer.sample.tf
   :language: javascript

Copy that file in it's entirety to the root of the project to start
customization. In the next sections, we'll describe the settings that you need
to configure.

Username and API Key
^^^^^^^^^^^^^^^^^^^^

You need to generate an API key for your SoftLayer account. This can be done
in the control panel at `http://softlayer.com<http://softlayer.com>`.

This token, along with your username, must be put in your softlayer.tf file.
Alternatively, if you don't want to put credentials in the terraform file,
you can set environment variables:

.. envvar:: SOFTLAYER_USERNAME

   The SoftLayer username

.. envvar:: SOFTLAYER_API_KEY

  The SoftLayer API key


Provisioning
------------

Once you're all set up with the provider, customize your modules (for
``control_count`` and ``worker_count``), run ``terraform get`` to prepare
Terraform to provision your cluster, ``terraform plan`` to see what will be
created, and ``terraform apply`` to provision the cluster. Afterwards, you can
use the instructions in :doc:`getting started <index>` to install
Mantl on your new cluster.
