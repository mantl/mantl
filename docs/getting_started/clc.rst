CenturyLinkCloud
=====================

.. versionadded:: 1.0.3

Terraform can use CLC to provision hosts for your cluster. You
can `download Terraform from terraform.io
<http://www.terraform.io/downloads.html>`_.

Documentation on using the CLC driver with terraform is `available here
<https://www.terraform.io/docs/providers/clc/index.html>`_.



NOTE: The CLC driver may not yet be available in the main terraform distribution.
See also https://github.com/CenturyLinkCloud/terraform-provider-clc if absent. 


Configuring Terraform
-----------------------------

From the project root, copy the template located at
``terraform/clc.sample.tf`` to ``./clc.tf``


In order to provision to CLC via terraform, login credentials are
required. Trial accounts with free credits are available, sign-up
`here <https://www.ctl.io>`_.


Account Setup
^^^^^^^^^^^^^


Be sure you have minimally set up you CLC account with the following:

- `A default network <https://control.ctl.io/Network/network/Create>`_

- Recommended: a dedicated user/pass for use in provisioning with terraform
  
  
Provider Settings
^^^^^^^^^^^^^^^^^

The driver accepts either via environment variables or credentials
inlined as provider config.


By environment variables:

.. envvar:: CLC_USERNAME

.. envvar:: CLC_PASSWORD

.. envvar:: CLC_ACCOUNT



Or conversely, via provider config:

.. code-block:: json

  ...
  variable ssh_key { default = "~/.ssh/id_rsa.pub" }

  provider "clc" {
    username = "<clc username goes here>"
    password = "<clc password goes here>"
    account  = "<clc account goes here>"
  }



Basic Settings
^^^^^^^^^^^^^^

``location`` is the datacenter where your cluster will be deployed
to. The `clc_group.mantl` server group will hold all the generated
nodes.

``{control|worker|edge}_count`` controls the number of nodes deployed
to each role.

``ssh_pass`` is the initial server password for root. It's advised to
test whatever password provided here before using it against
terraform.

``ssh_key`` is a public key that will be installed into root's
authorized_keys.


Additional settings are available for customization in
``./terraform/clc/node.tf``.




Provisioning
------------

Once you've reviewed and/or modified the settings, ``terraform get``
will prepare your cluster, ``terraform plan`` can be reviewed to check
the deployment, and ``terraform apply`` will provision the
cluster. Afterwards, you can use the instructions in :doc:`getting
started <index>` to install Mantl on your new cluster.



Post-Provisioning
-----------------

NOTE: currently the open-vm-tools package causes issues with kernel
upgrades in playbooks/upgrade-packages.yml. As part of the terraform
buildout, this package is removed to facilitate automated execution of
the upgrade playbook. It is not advised to leave this package missing on the
VMs, so after running upgrade-packages, execute the following to
reinstall it.

.. code-block:: shell

  ansible all -a "yum install -y open-vm-tools"` 
