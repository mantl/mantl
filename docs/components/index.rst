Components
==========

Microservices Infrastructure is made up of a number of components
which can be customized, generally using Ansible variables.

.. toctree::
   :maxdepth: 2

   collectd.rst
   consul.rst
   dnsmasq.rst
   haproxy.rst
   logstash.rst
   marathon.rst
   mesos.rst
   zookeeper.rst

The project also includes a number of Ansible roles that multiple components can
use:

.. toctree::

   common.rst
   consul-template.rst
