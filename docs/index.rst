Mantl documentation
==========================================

.. image:: /_static/gitter.svg
   :alt: Join the chat at https://gitter.im/CiscoCloud/mantl
   :target: https://gitter.im/CiscoCloud/mantl

.. image:: https://badge.waffle.io/CiscoCloud/mantl.png?label=ready&title=Ready
   :alt: Stories in Ready
   :target: https://waffle.io/CiscoCloud/microservices-infrastructure

Mantl is a modern platform for rapidly deploying globally
distributed services.

Features
--------

* `Terraform <https://terraform.io/>`_ deployment to multiple cloud and DNS providers
* `etcd <https://github.com/coreos/etcd>`_ distributed key-value store for Calico
* `Calico <http://www.projectcalico.org>`_ a new kind of virtual network
* `Mesos <https://mesos.apache.org/>`_ cluster manager for efficient resource
  isolation and sharing across distributed services
* `Marathon <https://mesosphere.github.io/marathon/>`_ for cluster management of
  long running containerized services
* `Chronos <https://mesos.github.io/chronos/>`_ a distributed task scheduler
* `Consul <http://consul.io>`_ for service discovery
* `Vault <http://vaultproject.io>`_ for managing secrets
* `Docker <http://docker.io>`_ container runtime
* `collectd <https://collectd.org/>`_ for metrics collection
* `Logstash <https://github.com/elastic/logstash>`_ for log forwarding
* `mesos-consul <https://github.com/CiscoCloud/mesos-consul>`_ populating Consul
  service discovery with Mesos tasks
* `marathon-consul <https://github.com/CiscoCloud/marathon-consul>`_ update
  consul k/v with Marathon tasks
* `ELK Stack <https://www.elastic.co/webinars/introduction-elk-stack>`_
* Multi-datacenter support
* High availablity
* Security

Contents:

.. toctree::
   :maxdepth: 2

   getting_started/index.rst
   components/index.rst
   addons.rst
   security/index.rst
   upgrading/index.rst
   packer.rst
   changelog.rst
   faq.rst
   license.rst

.. only:: html

   Indices and Tables
   ******************

   * :ref:`genindex`
   * :ref:`search`


License
-------
Copyright © 2015 Cisco Systems, Inc.

Licensed under the `Apache License, Version 2.0`_ (the "License").

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

.. _Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

This product includes software developed by the OpenSSL Project for use in the
OpenSSL Toolkit (http://www.openssl.org/)
