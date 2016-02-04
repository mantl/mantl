Upgrading
=========

Overview
--------

Starting with Mantl 0.6, our goal is to support a straightforward upgrade path
from a cluster running a previous release.

Upgrading from 0.5.1 to 0.6
---------------------------

If you have a running 0.5.1 cluster, you need to perform the following two
steps:

Upgrade Consul, Mesos, and Marathon
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

  ansible-playbook -e @security.yml playbooks/upgrade-0.5.1.yml

This playbook simply includes a couple of other playbooks that perform a rolling
upgrade of Consul, Mesos, and Marathon. If you want, you can run the following
playbooks independently:

* playbooks/upgrade-consul.yml
* playbooks/upgrade-mesos-marathon.yml

Upgrade to Mantl 0.6
~~~~~~~~~~~~~~~~~~~~

At this point, you can now upgrade the rest of the components to 0.6 with the
standard provisioning playbook:

.. code-block:: shell

  ansible-playbook -e @security.yml terraform.yml
