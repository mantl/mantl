Kafka
======

.. versionadded:: 1.1

This role installs the `Kafka Mesos Framework <https://github.com/mesos/kafka>`_
and starts Kafka brokers.

Installation
------------

After a successful initial run (from your customized ``sample.yml``), you can
install Kafka with ``ansible-playbook -e @security.yml addons/kafka.yml``. It
can take several minutes for all components to deploy and become healthy.

Accessing the Kafka Mesos REST API
----------------------------------

After the Kafka framework and the Kafka brokers have been successfully started
and initialized, it should be possible to access the Kafka Mesos REST API at
``/kafka`` on control nodes.

Default Configuration
---------------------

The default configuration of the Kafka brokers will require at least 3 worker
nodes that each have at least 4 CPUs and 4 GBs of memory available to Mesos.

Depending on your planned environment, you may wish to customize the sizing of
your Kafka cluster using the variables documented below.

Installing Kafka Manager
------------------------

Optionally, you can choose to install the `Kafka Manager
<https://github.com/yahoo/kafka-manager>`_ tool to help you manage your Kafka
deployment. To do so, you can install the addon with the
``kafka_manager_install`` variable set to ``yes``. For example:

.. code-block:: shell

   ansible-playbook -e @security.yml -e 'kafka_manager_install=yes' addons/kafka.yml

Customizing your Installation
-----------------------------

The size and configuration of your Kafka cluster is controlled by the variables
documented below.

Variables
---------

.. data:: kafka_scheduler_name

   The application ID of the Kafka scheduler in Marathon.

   default: "mantl/kafka"

.. data:: kafka_service_name

   The name of the service that is registered in Consul when the framework is
   deployed. This needs to match what would be derived via mesos-consul. For
   example, when ``kafka_scheduler_name`` is set to ``mantl/kafka``, the service
   name should be ``kafka-mantl``.

   default: "kafka-mantl"

.. data:: kafka_scheduler_cpu

   The amount of CPU to allocate to the Kafka scheduler instance (MB).

   default: 0.2

.. data:: kafka_scheduler_mem

   The amount of memory to allocate to the Kafka scheduler instance (MB).

   default: 512

.. data:: kafka_broker_count

   The number of Kafka brokers to start.

   default: 3

.. data:: kafka_broker_cpu

   The amount of CPU to allocate to each Kafka broker.

   default: 4

.. data:: kafka_broker_mem

   The amount of memory to allocate to each Kafka broker (MB).

   default: 4096

.. data:: kafka_broker_heap

   The amount of heap to allocate to each Kafka broker (MB).

   default: 4096

.. data:: kafka_broker_port

   The port to bind to for the Kafka brokers.

   default: 9092

.. data:: kafka_broker_options

   The Kafka options to pass to the brokers.

   default:

    - log.flush.interval.ms=10000
    - log.flush.interval=1000
    - num.recovery.threads.per.data.dir=1
    - delete.topic.enable=true
    - log.index.size.max.bytes=10485760
    - num.partitions=8
    - num.network.threads=3
    - socket.request.max.bytes=104857600
    - log.segment.bytes=536870912
    - log.cleaner.enable=true
    - zookeeper.connection.timeout.ms=1000000
    - log.flush.scheduler.interval.ms=2000
    - log.retention.hours=72
    - log.flush.interval.messages=20000
    - log.dirs=/mantl/a/dfs-data/kafka-logs\\,/mantl/b/dfs-data/kafka-logs\\,/mantl/c/dfs-data/kafka-logs\\,/mantl/d/dfs-data/kafka-logs\\,/mantl/e/dfs-data/kafka-logs\\,/mantl/f/dfs-data/kafka-logs
    - log.index.interval.bytes=4096
    - socket.receive.buffer.bytes=10485
    - min.insync.replicas=2
    - replica.lag.max.messages=10000000
    - replica.lag.time.max.ms=1000000
    - log.retention.check.interval.ms=3600000
    - message.max.bytes=20480
    - default.replication.factor=2
    - zookeeper.session.timeout.ms=500000
    - num.io.threads=8
    - auto.create.topics.enable=false
    - socket.send.buffer.bytes=1048576
    - topic.flush.intervals.ms=5000

.. data:: kafka_broker_jvm_options

   The Kafka JVM options to pass to the brokers.

   default:

    - "-Dcom.sun.management.jmxremote"
    - "-Dcom.sun.management.jmxremote.port=9010"
    - "-Dcom.sun.management.jmxremote.local.only=false"
    - "-Dcom.sun.management.jmxremote.authenticate=false"
    - "-Dcom.sun.management.jmxremote.ssl=false"

.. data:: kafka_manager_install

   Indicates whether or not to install the Kafka Manager tool.

   default: no

.. data:: kafka_manager_id

   The id of the Kafka Manager application in Marathon.

   default: mantl/kafka-manager

.. data:: kafka_manager_service_name

   The name of the service that is registered in Consul when Kafka Manager is
   deployed. This needs to match what would be derived via mesos-consul. For
   example, when ``kafka_manager_id`` is set to ``mantl/kafka-manager``, the
   service name should be ``kafka-manager-mantl``.

   default: kafka-manager-mantl

.. data:: kafka_manager_instances

   Number of Kafka Manager instances.

   default: 1

.. data:: kafka_manager_cpu

   The amount of CPU resources to allocate to each Kafka Manager instance.

   default: 0.5

.. data:: kafka_manager_mem

   The amount of memory to allocate to each Kafka Manager instance.

   default: 1024

.. data:: kafka_manager_load_balancer

   Indicates whether or not to expose the Kafka Manager on an edge node. Set to
   ``external`` if you wish to expose Kafka Manager via Traefik. Be aware that
   this will mean the application is available externally without
   authentication.

   default: off

