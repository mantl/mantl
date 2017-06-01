Kibana
=========

.. versionadded:: 1.2

The Kibana role is available to visualize and analyze Elasticsearch (by default)
data. Kibana is run via the `Kibana Mesos Framework
<https://github.com/mesos/kibana>`_. By default, it is configured to talk to an
Elasticsearch client node (which acts as a smart load balancer for the
Elasticsearch cluster) and includes a default sample dashboard.

.. note:: The standalone Kibana role is intended to be used for custom Kibana
          deployments. If you are looking for the full ELK stack for collecting
          and visualizing Mantl logs, you should install the ELK addon.

Installation
------------

As of 1.2, Kibana is distributed as an addon for Mantl. After a successful
initial run (from your customized ``sample.yml``), install it with
``ansible-playbook -e @security.yml addons/kibana.yml``. It can take several
minutes for all components to deploy and become healthy. It can also be
installed as part of the ELK addon.

Accessing User Interfaces
-------------------------

After the Kibana application has been successfully installed and initialized, it
should be possible to access its user interface directly from Mantl UI.

Kibana deployment
-----------------

By default, Kibana will be run via the Kibana Mesos framework. It is also
possible to run Kibana on Marathon. You can control this by setting the
``kibana_package`` variable. Set it to ``kibana`` to run Kibana via Marathon and
``kibana-mesos`` (the default) to run it via the Mesos framework.

Uninstalling the Kibana Addon
-----------------------------

The Kibana addon can be removed by running the following command:

.. code-block:: shell

   ansible-playbook -e @security.yml -e 'kibana_uninstall=true' addons/kibana.yml

This will remove Kibana from your cluster. 

Uninstalling Kibana (1.0.3)
---------------------------

On Mantl 1.0.3, we do not have an uninstall process for Kibana. However, it is
easy to disable it on your cluster. The following commands can be run to disable
Kibana:

.. code-block:: shell

   ansible 'role=control' -s -m shell -a 'consul-cli service-deregister kibana'
   ansible 'role=control' -s -m shell -a 'rm /etc/consul/kibana.json'
   ansible 'role=control' -s -m service -a 'name=kibana enabled=no state=stopped'

Variables
---------

.. data:: kibana_package

   The name of the package to use for the Kibana deployment. When set to
   ``kibana-mesos``, the Kibana Mesos framework will be used. When set to
   ``kibana``, Kibana will deployed in a Docker container running in Marathon.

   default: kibana-mesos

.. data:: kibana_logstash_config

   Indicates whether or not to configure Kibana for a typical ELK deployment. If
   true, it will create a logstash index in Kibana and create a sample
   dashboard.

   default: false

.. data:: kibana_id

   The id of the Kibana application in Marathon (Kibana on Marathon).

   default: mantl/kibana

.. data:: kibana_service

   The name of the service that is registered in Consul when Kibana is deployed.
   This needs to match what would be derived via mesos-consul. For example, when
   ``kibana_id`` is set to ``mantl/kibana``, the service name should be
   ``kibana-mantl`` (Kibana on Marathon).

   default: kibana-mantl

.. data:: kibana_image

   The Docker image to use for Kibana (Kibana on Marathon).

   default: ciscocloud/mantl-kibana:4.3.2.1

.. data:: kibana_elasticsearch_service

   The name of the Elasticsearch service registered in Consul for the Kibana
   instance to connect to (Kibana on Marathon).

   default: elasticsearch-client-mantl

.. data:: kibana_cpu

   The amount of CPU resources to allocate to each Kibana instance (Kibana on Marathon).

   default: 1.0

.. data:: kibana_ram

   The amount of memory to allocate to each instance of Kibana (MB) (Kibana on Marathon).

   default: 1024

.. data:: kibana_instances

   The number of Kibana instances to run (Kibana on Marathon).

   default: 1

.. data:: kibana_mesos_id

   The id of the Kibana framework application in Marathon (Kibana Mesos
   framework).

   default: mantl/kibana

.. data:: kibana_mesos_framework_name

   The name of the Kibana Mesos framework (Kibana Mesos framework). 

   default: kibana-mantl

.. data:: kibana_mesos_service

   The name of the service that is registered in Consul when the Kibana
   framework is deployed. This needs to match what would be derived via
   mesos-consul. For example, when ``kibana_mesos_id`` is set to
   ``mantl/kibana``, the service name should be ``kibana-mantl`` (Kibana Mesos
   framework).

   default: kibana-mantl

.. data:: kibana_mesos_image

   The Docker image to use for Kibana (Kibana Mesos framework).

   default: ciscocloud/mantl-kibana:4.3.2.1

.. data:: kibana_mesos_elasticsearch_service

   The name of the Elasticsearch service registered in Consul for the Kibana
   instance to connect to (Kibana Mesos framework).

   default: elasticsearch-client-mantl

.. data:: kibana_mesos_kibana_service

   The name of the Kibana service registered in Consul (Kibana Mesos framework).

   default: "{{ kibana_mesos_framework_name }}-task"

.. data:: kibana_mesos_scheduler_cpu

   The amount of CPU resources to allocate to the Kibana framework scheduler
   (Kibana Mesos framework).

   default: 0.5

.. data:: kibana_mesos_scheduler_ram

   The amount of memory to allocate to the Kibana framework scheduler (MB)
   (Kibana Mesos framework).

   default: 512

.. data:: kibana_mesos_executor_cpu

   The amount of CPU resources to allocate to each Kibana executor instance
   (Kibana Mesos framework).

   default: 1.0

.. data:: kibana_mesos_executor_ram

   The amount of memory to allocate to each Kibana executor instance (MB)
   (Kibana Mesos framework).

   default: 1024

.. data:: kibana_mesos_instances

   The number of Kibana executors to launch (Kibana Mesos framework).

   default: 1

.. data:: kibana_uninstall

   Run the role in uninstall mode to remove Kibana from your cluster.

   default: false
