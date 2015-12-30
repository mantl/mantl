Vagrant
=======

.. versionadded:: 0.6

`Vagrant <https://vagrantup.com/>`_ is used to "Create and configure
lightweight, reproducible, and portable development environments." We use it
to test Mantl locally before deploying to a cloud provider.

Our current setup creates a configurable number of virtual machines, and you can
define how many you want to build using a configuration file as described below.
One of the control servers provisions the others using the terraform.sample.yml
playbook.

Getting Started
---------------

Simply run ``vagrant up``. If you'd like to customize your build futher, you
can create a vagrant-config.yml file in the project's root directory with
variables as defined in the "Variables" section below.

Variables
---------

.. data:: worker_count

   The number of nodes with role=worker

.. data:: control_count

   The number of nodes with role=control

.. data:: worker_ip_start

   A base IP address which will have its last digit appended. For example, if
   this is set to "192.168.100.10", the first worker node will have the IP
   address 192.168.100.101, the second will have 192.168.100.102, etc.

.. data:: control_ip_start

   Similar to the above, but for control nodes.

.. data:: worker_memory

   The amount of memory in MB to allocate for worker node virtual machines. This
   setting is only valid for the virtualbox provider.

.. data:: worker_cpus

   The number of CPUs to allocate for worker node virtual machines. This setting
   is only valid for the virtualbox provider.

.. data:: control_memory

   The amount of memory in MB to allocate for control node virtual machines.
   This setting is only valid for the virtualbox provider.

.. data:: control_cpus

   The number of CPUs to allocate for control node virtual machines. This
   setting is only valid for the virtualbox provider.

.. data:: addons

   An array of addon Ansible playbooks to run after the main playbook. Each
   entry should map to a playbook in the ``./addons`` directory. For example, to
   attempt to run the GlusterFS addon (``./addons/glusterfs.yml`), you would add
   a ``glusterfs`` entry.

Limitations
-----------

Mantl will likely experience stability issues with one control node. As stated
in the `Consul docs <https://www.consul.io/docs/guides/bootstrapping.html>`_,
this setup is inherently unstable.

Moreover two features of Mantl are not supported on Vagrant: GlusterFS and
Traefik. The Traefik UI will show a 403 forbidden error, because there are no
edge nodes. GlusterFS support might happen in the future, but it is an optional
feature and not a priority.
