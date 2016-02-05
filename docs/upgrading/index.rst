Upgrading
=========

Overview
--------

Beginning with Mantl 0.6,  our goal is to support a straightforward upgrade path
from a cluster running a previous release.

However, upgrade support should be considered alpha at this time; it has not
been extensively tested on production clusters. Please use with caution and
report any issues you have with the process.

Upgrading from 0.5.1 to 0.6
---------------------------

If you have a running 0.5.1 cluster, you need to perform the following steps:

Update security.yml
~~~~~~~~~~~~~~~~~~~

Mantl 0.6 requires some additional settings in the ``security.yml`` file that
you generated when you built your cluster. To auto-generate the necessary
settings, you simply need to re-run ``security-setup``:

.. code-block:: shell

  ./security-setup

Of course, if you customized your security settings (manually or using the CLI
arguments), you should be careful to re-run ``security-setup`` the same way.

For your reference, the following settings have been added:

* consul_acl_marathon_token
* consul_acl_secure_token
* consul_dns_domain

A note on consul_dns_domain
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Prior to 0.6, the ansible ``consul_dns_domain`` variable was defined in a number
of different playbooks. It is now included in ``security.yml`` and can be
customized from a single location. This simplifies the configuration and reduces
the likelihood of mistakes. If you are working with a customized
``terraform.yml`` file, you should remove all ``consul_dns_domain`` definitions
from it and ensure ``consul_dns_domain`` is set as desired in your
``security.yml``.

Upgrade Distributive, Consul, Mesos, and Marathon
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

  ansible-playbook -e @security.yml playbooks/upgrade-0.5.1.yml

This playbook performans a Distributive upgrade and includes a couple of other
playbooks that perform a rolling upgrade of Consul, Mesos, and Marathon.

Upgrade to Mantl 0.6
~~~~~~~~~~~~~~~~~~~~

At this point, you can now upgrade the rest of the components to 0.6 with the
standard provisioning playbook:

.. code-block:: shell

  ansible-playbook -e @security.yml terraform.yml
