Components
==========

Microservices Infrastructure is made up of a number of components
which can be customized, generally using Ansible variables.

.. toctree::
   :maxdepth: 1

   collectd.rst
   consul.rst
   dnsmasq.rst
   docker.rst
   haproxy.rst
   logstash.rst
   marathon.rst
   mesos.rst
   zookeeper.rst

The project also includes a number of Ansible roles that multiple components can
use:

.. toctree::
   :maxdepth: 1

   common.rst
   consul-template.rst
   logrotate.rst
