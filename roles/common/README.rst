Common
======

.. versionadded:: 0.1

The common role prepares a system with functionality needed between multiple
roles. Specifically:

- sets timezone to UTC
- configures hosts for simple name resolution (before Consul DNS is set up)
- installs common software like the base distributive package and pip
- adds :doc:`users </getting_started/ssh_users>`.
- adds SSL certificates created by :doc:`security-setup
  </security/security_setup>` to the root CA store
- does various workarounds for cloud providers

Variables
---------

.. data:: use_host_domain

   Add a domain component to hosts in /etc/hosts

   default: ``false``

.. data:: host_domain

   The domain component to add to hosts in /etc/hosts

   default: ``novalocal``
