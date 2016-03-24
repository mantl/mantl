Components
==========

Mantl is made up of a number of components which can be customized, generally
using Ansible variables.

.. toctree::
   :maxdepth: 1

   calico.rst
   chronos.rst
   collectd.rst
   consul.rst
   dnsmasq.rst
   docker.rst
   elk.rst
   etcd.rst
   glusterfs.rst
   haproxy.rst
   logstash.rst
   marathon.rst
   mesos.rst
   traefik.rst
   zookeeper.rst

The project also includes a number of Ansible roles that multiple components can
use:

.. toctree::
   :maxdepth: 1

   common.rst
   consul-template.rst
   logrotate.rst
   nginx.rst

The following technology previews are also included. These may be used more
fully in the future, but now just exist for preview purposes to gather feedback
and build initial implementations against:

.. toctree::
   :maxdepth: 1

   vault.rst

Mantl includes some logic that is provided via our own packaging system, and so
is not visible in the Ansible roles. Here are the links to our package sources:

 - `mantl-packaging <https://github.com/asteris-llc/mantl-packaging>`_
 - `mesos-packaging <https://github.com/asteris-llc/mesos-packaging>`_
