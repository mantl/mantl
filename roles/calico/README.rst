Calico
======

.. versionadded:: 0.4

`Calico <http://www.projectcalico.org>`_ is used in the project to add the IP
per container functionality. Calico connects Docker containers through IP no matter
which worker node they are on. Calico uses :doc:`etcd` to distribute information
about workloads, endpoints, and policy to each worker node. Endpoints are
network interfaces associated with workloads. Calico is deployed in the Docker
container on each worker node and managed by systemd. Any workload managed by
Calico is registered as a service in Consul.

Calico is not enabled by default. In order to run Calico, you should make a
couple of changes to your ``mantl.yml``. You will need to add the ``etcd``
role into the ``roles`` section for ``all`` hosts:

.. code-block:: json

   - hosts: all
     ...
     roles:
       - common
       ...
       - etcd

And you need to add the ``calico`` role to the ``role=worker`` hosts:

.. code-block:: json

   - hosts: role=worker
     roles:
       ...
       - calico

Modes
^^^^^

Calico can run a public cloud environment that does not allow either L3 peering
or L2 connectivity between Calico hosts. Calico will then route traffic between
the Calico hosts using IP in IP mode. At this time, the full node-to-node BGP
mesh is supported and configured in OpenStack only. Other cloud environments
are set up with the IP in IP mode.

Mesos
^^^^^

We pass the environment variable ``DOCKER_HOST`` to the executor using the
flag ``--executor_environment_variables`` (added in Mesos v0.23.0), and thus
the subsequent tasks:

.. code-block:: json

   {
     "DOCKER_HOST": "localhost:2377"
   }

This allows Calico to set up networking automatically by routing Docker API
requests through the `Powerstrip <https://github.com/clusterhq/powerstrip>`_
proxy that is running on port ``2377`` on each Mesos slave host.

Marathon
^^^^^^^^

When you start containers on top of Marathon, you will need to add two
environment variables to your JSON file: ``CALICO_IP`` and ``CALICO_PROFILE``.
You can assign an IP address to ``CALICO_IP`` explicitly or set ``auto`` and it
will be allocated automatically. If the profile set with ``CALICO_PROFILE``
doesn't exist, it will be created automatically. If you don't provide the two
variables, the Docker default network settings will be applied. The variable
``SERVICE_PORT`` is optional, it registers a service port in Consul for your
application. You can make an SRV query to return this port.

Example:

.. code-block:: json

   {
     "container": {
       "type": "DOCKER",
       "docker": {
         "image": "busybox"
       }
     },
     "id": "testapp",
     "instances": 1,
     "env": {
       "CALICO_IP": "auto",
       "CALICO_PROFILE": "dev",
       "SERVICE_PORT": "3000"
     },
     "cpus": 0.1,
     "mem": 32,
     "uris": [],
     "cmd": "while sleep 10; do date -u +%T; done"
   }

Consul
^^^^^^

When you start a workload on Marathon with the proper environment variables
as ``CALICO_IP`` and ``CALICO_PROFILE``, the workload is registered in Consul
as a service. The Powerstrip logic was extended in this case.
The registered name is constructed in this way: ``MARATHON_APP_ID`` plus
``-direct`` suffix. For example, if you create a workload with the name of
``testapp``, then the ``testapp-direct`` service will be registered in Consul.

Thus, you have the option to query Consul in two ways:

1. In order to obtain Docker host IP addresses where your workload is running:

.. code-block:: shell

   dig @localhost -p 8600 testapp.service.consul

2. To resolve IP addresses from the Calico network:

.. code-block:: shell

   dig @localhost -p 8600 testapp-direct.service.consul

In the above examples, adjust the `.consul` domain as needed if you customized
it when building your cluster.

calicoctl
^^^^^^^^^

You can use the ``calicoctl`` command line tool to manually configure and start
the Calico services, interact with the etcd datastore, define and apply network
and security policies, and other.

Examples:

.. code-block:: shell

   calicoctl help
   calicoctl status
   calicoctl profile show --detailed
   calicoctl endpoint show --detailed
   calicoctl pool show

Logging
^^^^^^^

All components log to directories under ``/var/log/calico`` inside
the calico-docker container. By default this is mapped to
the ``/var/log/calico`` directory on the host. Files are automatically rotated,
and by default 10 files of 1MB each are kept.

Variables
---------

You can use these variables to customize your Calico installation. For more
information, refer to the :doc:`etcd` configuration.

.. data:: etcd_service_name

   Set the ``ETCD_AUTHORITY`` environment variable that is used by Calico Docker
   container and the CLI tool ``calicoctl``. The value of this variable is
   a Consul service that must be resolved through DNS

   Default: ``etcd.service.consul``

.. data:: etcd_client_port

   Port for etcd client communication

   Default: ``2379``

.. data:: calico_network

   Containers are assigned IPs from this network range

   Default: ``192.168.0.0/16``

.. data:: calico_profile

   Endpoints are added to this profile for interconnectivity

   Default: ``dev``
