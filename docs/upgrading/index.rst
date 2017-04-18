Upgrading
=========

Overview
--------

Beginning with Mantl 1.0,  our goal is to support a straightforward upgrade path
from a cluster running a previous release.

However, upgrade support should be considered alpha at this time; it has not
been extensively tested on production clusters. Please use with caution and
report any issues you have with the process.

Upgrading OS packages
---------------------

We provide two playbooks for upgrading OS-level system packages on a cluster:
``playbooks/upgrade-packages.yml`` and ``playbooks/rolling-upgrade-packages.yml``.
The first playbook upgrades all nodes on your cluster in parallel, and the
second upgrades each node serially. You want the use the rolling upgrade on a
cluster that is already running consul; otherwise, you will likely lose quorum
and destabilize your cluster.

Upgrading from 1.1 to 1.2
---------------------------

If you have a running 1.1 cluster, you need to perform the following steps:

Update security.yml
~~~~~~~~~~~~~~~~~~~

Mantl 1.2 requires an additional setting in the ``security.yml`` file that you
generated when you built your cluster. To auto-generate the necessary settings,
you simply need to re-run ``security-setup``:

.. code-block:: shell

  ./security-setup

Of course, if you customized your security settings (manually or using the CLI
arguments), you should be careful to re-run ``security-setup`` the same way.

Core Component Rolling Upgrade
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

  ansible-playbook -e @security.yml playbooks/upgrade-1.1.yml

This playbook performs a rolling update of consul which is required to support
new features in Mantl 1.2.

Upgrade to Mantl 1.2
~~~~~~~~~~~~~~~~~~~~

At this point, you can now upgrade the rest of the components to 1.2 with the
standard provisioning playbook:

.. code-block:: shell

  ansible-playbook -e @security.yml mantl.yml

If you customized variables with ``-e`` when building your 1.1 cluster, you will
likely want to include the same variables when running the 1.2 version of the
playbook. For example:

.. code-block:: shell

  ansible-playbook -e @security.yml -e consul_dc=mydc mantl.yml

Upgrading from 1.0.3 to 1.1
---------------------------

If you have a running 1.0.3 cluster, you need to perform the following steps:

Update security.yml
~~~~~~~~~~~~~~~~~~~

Mantl 1.0 requires some additional settings in the ``security.yml`` file that
you generated when you built your cluster. To auto-generate the necessary
settings, you simply need to re-run ``security-setup``:

.. code-block:: shell

  ./security-setup

Of course, if you customized your security settings (manually or using the CLI
arguments), you should be careful to re-run ``security-setup`` the same way.

The main change was a switch to using a single certificate for internal nginx
proxies.

Core Component Rolling Upgrade
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

  ansible-playbook -e @security.yml playbooks/upgrade-1.0.3.yml

This playbook performs a rolling update of several core components including
consul, nginx-consul based services, and mantl-dns. Due to compatibility issues,
we also disable the collectd Docker plugin.

Upgrade to Mantl 1.1
~~~~~~~~~~~~~~~~~~~~

At this point, you can now upgrade the rest of the components to 1.1 with the
standard provisioning playbook:

.. code-block:: shell

  ansible-playbook -e @security.yml mantl.yml

If you already have a pre-1.1 mantl.yml, you will want to incorporate the 1.1
changes (see ``sample.yml``). Also, if you customized variables with
``-e`` when building your 1.0.3 cluster, you will likely want to include the
same variables when running the 1.1 version of the playbook. For example:

.. code-block:: shell

  ansible-playbook -e @security.yml -e consul_dc=mydc mantl.yml

Upgrading from 0.5.1 to 1.0
---------------------------

If you have a running 0.5.1 cluster, you need to perform the following steps:

Update security.yml
~~~~~~~~~~~~~~~~~~~

Mantl 1.0 requires some additional settings in the ``security.yml`` file that
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

Prior to 1.0, the ansible ``consul_dns_domain`` variable was defined in a number
of different playbooks. It is now included in ``security.yml`` and can be
customized from a single location. This simplifies the configuration and reduces
the likelihood of mistakes. If you are working with a customized
``mantl.yml`` file, you should remove all ``consul_dns_domain`` definitions
from it and ensure ``consul_dns_domain`` is set as desired in your
``security.yml``.

Upgrade Distributive, Consul, Mesos, and Marathon
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: shell

  ansible-playbook -e @security.yml playbooks/upgrade-0.5.1.yml

This playbook performs a Distributive upgrade and includes a couple of other
playbooks that perform a rolling upgrade of Consul, Mesos, and Marathon.

Upgrade to Mantl 1.0
~~~~~~~~~~~~~~~~~~~~

At this point, you can now upgrade the rest of the components to 1.0 with the
standard provisioning playbook:

.. code-block:: shell

  ansible-playbook -e @security.yml mantl.yml

Upgrading from 1.1 to 1.2
-------------------------

Mantl 1.2 removed the ``consul_dns_domain`` variable. Services are reachable via
``<service-name>.service.consul`` and nodes via ``<hostname>.node.consul``,
instead of ``<service-name>.service.<consul-dns-domain>`` and
``<hostname>.node.<consul-dns-domain>`` respectively.
