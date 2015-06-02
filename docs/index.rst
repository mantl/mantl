microservices-infrastructure documentation
==========================================

microservices-infrastructure is a modern platform for rapidly deploying globally
distributed services.

Features
--------
* `Mesos`_ cluster manager for efficient resource isolation and sharing across
  distributed services
* `Marathon`_ for cluster management of long running containerized services
* `Consul`_ for service discovery
* `Vault`_ for managing secrets
* `Docker`_ container runtime
* Multi-datacenter support
* High availablity

Contents:

.. toctree::
   :maxdepth: 2

   getting_started/index.rst
   components/index.rst
   security/index.rst
   changelog.rst
   roadmap.rst
   license.rst

.. only:: html 

   Indices and Tables
   ******************

   * :ref:`genindex`
   * :ref:`search`

.. _Mesos: https://mesos.apache.org/
.. _Consul: http://consul.io
.. _Vault: http://vaultproject.io
.. _Docker: http://docker.io
.. _Marathon: https://mesosphere.github.io/marathon/


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
