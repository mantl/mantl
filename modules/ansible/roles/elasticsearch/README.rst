Elasticsearch
==============

.. versionadded:: 1.2

This role runs an Elasticsearch cluster via the `Elasticsearch Mesos Framework
<https://github.com/mesos/elasticsearch>`_. 

.. note:: The standalone Elasticsearch role is intended to be used for custom
          Elasticsearch deployments. If you are looking for the full ELK stack
          for collecting and visualizing Mantl logs, you should install the ELK
          addon.

Installation
------------

As of 1.2, Elasticsearch is distributed as an addon for Mantl. After a
successful initial run (from your customized ``sample.yml``), install it with
``ansible-playbook -e @security.yml addons/elasticsearch.yml``. It can take
several minutes for all components to deploy and become healthy.

Accessing User Interfaces
-------------------------

After the Elasticsearch framework has been successfully installed and
initialized, it should be possible to access its user interface directly from
Mantl UI.

Default Configuration
---------------------

The default configuration of the Elasticsearch cluster will require at least 4
worker nodes, each having at least 1 full CPU and 2+ GBs of memory available to
Mesos. In addition, each worker node will need to have at least 10 GBs of free
disk space.

While a cluster of this size will be sufficient to evaluate and test
Elasticsearch on Mantl, we encourage you to review the configuration variables
below to size the cluster as appropriate for your environment.

Customizing your Installation
-----------------------------

The size of your Elasticsearch cluster is controlled by the variables documented
below. As an example, let's say that you just wanted to stand up a small
Elasticsearch cluster for evaluation purposes. You only want to run a single
node since you are not worried about high availability or data safety in this
scenario. To do this, create a new yaml file (``elasticsearch.yml``, for
example) that looks something like this:

.. code-block:: yaml

  ---
  elasticsearch_ram: 512
  elasticsearch_executor_ram: 512
  elasticsearch_cpu: 0.5
  elasticsearch_executor_cpu: 0.5
  elasticsearch_nodes: 1

In this example, we are configuring both the Elasticsearch framework scheduler
and the Elasticsearch nodes (executors) to each use 512 MB of memory and a half
a CPU each. We are also indicating that we only want a single Elasticsearch node
launched in the cluster.

When you install the Elasticsearch addon, you can tell ansible to use this yaml
file to configure your installation:

.. code-block:: shell

   ansible-playbook -e @security.yml -e @elasticsearch.yml addons/elasticsearch.yml

With this configuration, the Elasticsearch client node will still be deployed
with its default configuration. Of course, you can customize further as needed.

Uninstalling the Elasticsearch addon
------------------------------------

The Elasticsearch addon can be removed by running the following command:

.. code-block:: shell

   ansible-playbook -e @security.yml -e 'elasticsearch_uninstall=true' addons/elasticsearch.yml

This will remove the Elasticsearch framework and the Elasticsearch client node
from your cluster. By default, the Elasticsearch data directories will
not be removed. If you do not need to preserve your Elasticsearch data, you can
set the ``elasticsearch_remove_data`` variable to true when you run the
uninstall:

.. code-block:: shell

   ansible-playbook -e @security.yml -e 'elasticsearch_uninstall=true elasticsearch_remove_data=true' addons/elasticsearch.yml

Uninstalling the Elasticsearch Framework (1.0.3)
------------------------------------------------

Uninstalling the Elasticsearch framework involves several steps. Below are
examples of the commands that you can run to completely remove the framework
from your cluster. You will need to adjust the ``creds``, ``url``, and
``control_node`` variables to values that are applicable to your cluster. You
will also need to have the `jq <https://stedolan.github.io/jq/>`_ utility
installed to follow this example.

.. code-block:: shell

      export creds='admin:password'
      export url=https://mantl-control-01
      export control_node=mantl-control-01

      # remove scheduler from marathon
      curl -sku $creds -XDELETE $url/marathon/v2/apps/elasticsearch

      # find the mesos framework id
      frameworkId=$(curl -sku $creds $url/api/1/frameworks | jq -r '.[] | select(.name == "elasticsearch") | .id')

      # remove the mesos framework
      curl -sku $creds -XDELETE $url/api/1/frameworks/$frameworkId

      # clean up mesos framework state from zookeeper
      ansible $control_node -s -m shell -a 'zookeepercli -servers zookeeper.service.consul -force -c rmr /elasticsearch'

      # delete all elasticsearch data (optional)
      ansible 'role=worker' -s -m shell -a 'rm -rf /data'

Variables
---------

.. data:: elasticsearch_ram

   The amount of memory to allocate to the Elasticsearch scheduler instance
   (MB).

   default: 1024

.. data:: elasticsearch_java_opts

   The JAVA_OPTS value that should be set in the environment.

   default: -Xms1g -Xmx1g

.. data:: elasticsearch_executor_ram

   The amount of memory to allocate to each Elasticsearch executor instance
   (MB).

   default: 2048

.. data:: elasticsearch_disk

   The amount of Disk resource to allocate to each Elasticsearch executor
   instance (MB).

   default: 10240

.. data:: elasticsearch_cpu

   The amount of CPU resources to allocate to the Elasticsearch scheduler.

   default: 1.0

.. data:: elasticsearch_executor_cpu

   The amount of CPU resources to allocate to each Elasticsearch executor
   instance.

   default: 1.0

.. data:: elasticsearch_nodes

   Number of Elasticsearch executor instances.

   default: 3

.. data:: elasticsearch_cluster_name

   The name of the Elasticsearch cluster.

   default: "mantl"

.. data:: elasticsearch_service

   The name of the service that is registered in Consul when the framework is
   deployed. This needs to match what would be derived via mesos-consul. For
   example, when ``elasticsearch_framework_name`` is set to
   ``mantl/elasticsearch``, the service name should be ``elasticsearch-mantl``.

   default: "elasticsearch-mantl"

.. data:: elasticsearch_executor_name

   The name of the executor tasks in Mesos.

   default: "elasticsearch-executor-mantl"

.. data:: elasticsearch_framework_version

   The version of the Elasticsearch mesos framework. 

   default: "1.0.1-1"

.. data:: elasticsearch_framework_name

   The name of the Elasticsearch mesos framework. 

   default: "mantl/elasticsearch"

.. data:: elasticsearch_framework_ui_port

   The port that the Elasticsearch framework user interface listens on.

   default: 31100

.. data:: elasticsearch_client_id

   The id of the elasticsearch-client application in Marathon.

   default: "mantl/elasticsearch-client"

.. data:: elasticsearch_client_service

   The name of the service that is registered in Consul when the Elasticsearch
   client node is deployed. This needs to match what would be derived via
   mesos-consul. For example, when ``elasticsearch_client_id`` is set to
   ``mantl/elasticsearch-client``, the service name should be
   ``elasticsearch-client-mantl``.

   default: "elasticsearch-client-mantl"

.. data:: elasticsearch_client_elasticsearch_service

   The name of the service registered in Consul for the Elasticsearch client
   node to connect to.

   default: "transport_port.{{ elasticsearch_executor_name }}"

.. data:: elasticsearch_client_client_port

   The HTTP port for the Elasticsearch client node to listen on.

   default: 9200

.. data:: elasticsearch_client_transport_port

   The transport port for the Elasticsearch client node to listen on.

   default: 9300

.. data:: elasticsearch_client_cpu

   The amount of CPU resources to allocate to the Elasticsearch client node.

   default: 1.0

.. data:: elasticsearch_client_ram

   The amount of memory to allocate to the Elasticsearch client node (MB).

   default: 2048

.. data:: elasticsearch_client_java_opts

   The JAVA_OPTS value that should be set in the environment.

   default: -Xms1g -Xmx1g

.. data:: elasticsearch_uninstall

   Run the role in uninstall mode to remove Elasticsearch from your cluster.

   default: false

.. data:: elasticsearch_remove_data

   Indicate whether to delete elasticsearch data directories when uninstalling
   Elasticsearch.

   default: false
