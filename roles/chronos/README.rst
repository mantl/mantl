Chronos
=========

.. versionadded:: 0.1

`Chronos <http://http://mesos.github.io/chronos/>`_ is a distributed and
fault-tolerant scheduler that runs on top of Apache Mesos that can be used for
job orchestration. You can think of it as distributed cron service. It supports
custom Mesos executors as well as the default command executor. By default,
Chronos executes sh (on most systems bash) scripts.

Installation
------------

As of 1.1, Chronos is distributed as an addon for Mantl. After a successful
initial build (from your customized ``sample.yml``), you can install it by
running:

.. code-block:: shell

   ansible-playbook addons/chronos.yml

It can take a few minutes before Chronos becomes available and healthy.

Accessing the Chronos User Interface
------------------------------------

After Chronos has been successfully installed and initialized, it should be
possible to access the user interface directly from Mantl UI.

Default Configuration
---------------------

The default configuration of the Chronos addon will require at 1 worker node
with at least 1 CPU and 1 GB of memory available.

Customizing your Installation
-----------------------------

There are a number of configuration options available for Chronos (each
documented in the Variables section below).

As an example, let's say you wanted to run 3 Chronos instances for
high-availability purposes and you wanted each to have more CPU and memory
allocated. To do this, create a new yaml file (``chronos.yml``, for example)
that looks something like this:

.. code-block:: yaml

  ---
  chronos_instances: 3
  chronos_cpus: 2.0
  chronos_mem: 2048.0

When you install the Chronos addon, you can tell ansible to use this yaml file
to configure your installation:

.. code-block:: shell

   ansible-playbook -e @chronos.yml addons/chronos.yml

Uninstalling the Chronos addon
------------------------------

Uninstalling the Chronos addon can be done with a single API call. For example:

.. code-block:: shell

   export creds='admin:password'
   export url=https://mantl-control-01

   # uninstall chronos framework
   curl -sku $creds -XDELETE -d "{\"name\": \"chronos\"}" $url/api/1/install

You will need to adjust the ``creds`` and ``url`` variables with values that are
applicable to your cluster.

Upgrading from 1.0
------------------

If you are upgrading from a Mantl 1.0 cluster that is already running Chronos,
there is actually little reason to switch over to the addon version that runs in
Marathon. Feel free to continue using your existing Chronos installation.
However, if for some reason you want to switch, you can run the following steps
to disable the existing Chronos install.

.. warning::

   Please note that you will need to recreate any tasks you already have
   scheduled in Chronos. They will not be automatically migrated.

.. code-block:: shell

   ansible 'role=control' -s -m shell -a 'consul-cli service-deregister chronos'
   ansible 'role=control' -s -m shell -a 'rm /etc/consul/chronos.json'
   ansible 'role=control' -s -m service -a 'name=chronos enabled=no state=stopped'

The new method of installing Chronos requires a version of mantl-api later than
0.1.7. You can upgrade mantl-api manually, or run a sample playbook from a more
recent version of Mantl (after 1.0.4) to get it. After upgrading mantl-api, you
can install the addon in the usual way:

.. code-block:: shell

   ansible-playbook addons/chronos.yml

Variables
---------

.. data:: chronos_cassandra_port

   Port for Cassandra.

   default: 9042

.. data:: chronos_cassandra_ttl

   TTL for records written to Cassandra.

   default: 31536000

.. data:: chronos_cpus

   CPU shares to allocate to each Chronos instance.

   default: 1.0

.. data:: chronos_instances

   Number of Chronos instances to run.

   default: 1

.. data:: chronos_decline_offer_duration

   The duration (milliseconds) for which to decline offers by default.

   default: 5000

.. data:: chronos_disable_after_failures

   Disables a job after this many failures have occurred.

   default: 0

.. data:: chronos_failover_timeout

   The failover timeout in seconds for Mesos.

   default: 604800

.. data:: chronos_failure_retry

   Number of ms between retries.

   default: 60000

.. data:: chronos_framework_name

   The framework name.

   default: "chronos"

.. data:: chronos_graphite_reporting_interval

   Graphite reporting interval (seconds).

   default: 60

.. data:: chronos_hostname

   The advertised hostname stored in ZooKeeper so another standby host can
   redirect to this elected leader.

   default: "$HOST"

.. data:: chronos_id

   Unique identifier for the app consisting of a series of names separated by
   slashes.

   default: "/chronos"

.. data:: chronos_mem

   Memory (MB) to allocate to each Chronos instance.

   default: 1024.0

.. data:: chronos_mesos_task_cpu

   Number of CPUs to request from Mesos for each task.

   default: 0.1

.. data:: chronos_mesos_task_disk

   Amount of disk capacity to request from Mesos for each task (MB).

   default: 256.0

.. data:: chronos_mesos_task_mem

   Amount of memory to request from Mesos for each task (MB).

   default: 128.0

.. data:: chronos_min_revive_offers_interval

   Do not ask for all offers (also already seen ones) more often than this
   interval (ms).

   default: 5000

.. data:: chronos_reconciliation_interval

   Reconciliation interval in seconds.

   default: 600

.. data:: chronos_revive_offers_for_new_jobs

   Whether to call reviveOffers for new or changed jobs.

   default: false

.. data:: chronos_schedule_horizon

   The look-ahead time for scheduling tasks in seconds.

   default: 60

.. data:: chronos_task_epsilon

   The default epsilon value for tasks, in seconds.

   default: 60

.. data:: chronos_zk_hosts

   The list of ZooKeeper servers for storing state.

   default: "zookeeper.service.consul:2181"

.. data:: chronos_zk_timeout

   The timeout for ZooKeeper in milliseconds.

   default: 10000
