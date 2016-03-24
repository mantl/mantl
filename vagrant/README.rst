Vagrant
=======

.. versionadded:: 1.0

`Vagrant <https://vagrantup.com/>`_ is used to "Create and configure
lightweight, reproducible, and portable development environments." We use it
to test Mantl locally before deploying to a cloud provider.
Our current setup creates a configurable number of virtual machines, and you can
define how many you want to build using a configuration file as described below.
One of the control servers provisions the others using the sample.yml
playbook.

Getting Started
---------------

Simply run ``vagrant up``. If you'd like to customize your build futher, you
can create a vagrant-config.yml file in the project's root directory with
variables as defined in the "Variables" section below.

Variables
---------

You can find the default values for all these variables in the ``config_hash``
in the provided Vagrantfile.

.. data:: worker_count, control_count, edge_count

   The number of nodes with this role.

.. data:: worker_ip_start, control_ip_start, edge_ip_start

   A base IP address which will have its last digit appended. For example, if
   ``worker_ip_start`` is set to "192.168.100.10", the first worker node will
   have the IP address 192.168.100.101, the second will have 192.168.100.102,
   etc.

.. data:: worker_memory, control_memory, edge_memory

   The amount of memory in MB to allocate for each kind of VM. This setting is
   only valid for the virtualbox provider.

.. data:: worker_cpus, control_cpus, edge_cpus

   The number of CPUs to allocate for each kind of VM. This setting is only
   valid for the virtualbox provider.

.. data:: network

   Default: private. Which type of Vagrant network to provision. See
   https://docs.vagrantup.com/v2/networking/index.html

.. data:: playbooks

   An array of paths to Ansible playbooks to run during the provisioning step.
   For example, to attempt to run the GlusterFS addon
   (``./addons/glusterfs.yml``), you would add a
   ``/vagrant/addons/glusterfs.yml`` entry. You can also use this directive to
   run playbooks other than ``sample.yml`` after provisioning for the
   first time, by modifying this variable and running ``vagrant provision``.

Limitations
-----------

Mantl will likely experience stability issues with one control node. As stated
in the `Consul docs <https://www.consul.io/docs/guides/bootstrapping.html>`_,
this setup is inherently unstable.

Moreover, GlusterFS and LVM are not supported on Vagrant, and Traefik
(edge nodes) are turned off by default. GlusterFS support might happen in the
future, but it is an optional feature and not a priority.
