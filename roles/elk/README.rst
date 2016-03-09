ELK
=========

.. versionadded:: 1.0

The ELK role combines Elasticsearch, Logstash, and Kibana to provide automatic
log shipping and metrics collection from all Mantl nodes to an Elasticsearch
cluster. Kibana is available to visualize and analyze this data.

This role runs an Elasticsearch cluster via the `Elasticsearch Mesos Framework
<https://github.com/mesos/elasticsearch>`_. It also configures Logstash on all
nodes to forward logs to that cluster. Finally, Kibana is installed on all
control nodes and is configured to talk to Elasticsearch and includes a default
sample dashboard.

Installation
------------

As of 1.0, the ELK stack is distributed as an addon for Mantl. After a
successful initial run (from your customized ``sample.yml``), install
it with ``ansible-playbook -e @security.yml addons/elk.yml``.

Accessing User Interfaces
-------------------------

After the Elasticsearch framework and the Kibana application have been
successfully installed and initialized, it should be possible to access their
corresponding user interfaces directly from Mantl UI.

Default Configuration
---------------------

The default configuration of the ELK stack will require at least 4 worker nodes,
each having at least 1 full CPU and 1 GB of memory available to Mesos. In
addition, each worker node will need to have at least 5 GBs of free disk space.

While a cluster of this size will be sufficient to evaluate and test the ELK
stack on Mantl, we encourage you to review the configuration variables below to
size the cluster as appropriate for your environment.

Customizing your Installation
-----------------------------

The size of your elasticsearch cluster is controlled by the variables documented
below. As an example, let's say that you just wanted to stand up an ELK stack on
a small cluster for evaluation purposes. You only want to run a single node
since you are not worried about high availability or data safety in this
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

When you install the ELK addon, you can tell ansible to use this yaml file to
configure your installation:

.. code-block:: shell

   ansible-playbook -e @security.yml -e @elasticsearch.yml addons/elk.yml

Uninstalling the Elasticsearch Framework
----------------------------------------

Uninstalling the Elasticsearch framework currently involves several steps. Below
are examples of the commands that you can run to completely remove the framework
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

Uninstalling Kibana
-------------------

While we currently do not have an uninstall process for Kibana, it is easy to
disable it on your cluster. The following commands can be run to disable Kibana:

.. code-block:: shell

   ansible 'role=control' -s -m shell -a 'consul-cli service-deregister kibana'
   ansible 'role=control' -s -m shell -a 'rm /etc/consul/kibana.json'
   ansible 'role=control' -s -m service -a 'name=kibana enabled=no state=stopped'

Variables
---------

.. data:: elasticsearch_ram

   The amount of memory to allocate to the Elasticsearch scheduler instance
   (MB).

   default: 1024

.. data:: elasticsearch_executor_ram

   The amount of memory to allocate to each Elasticsearch executor instance
   (MB).

   default: 1024

.. data:: elasticsearch_disk

   The amount of Disk resource to allocate to each Elasticsearch executor
   instance (MB).

   default: 5120

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

.. data:: framework_version

   The version of the Elasticsearch mesos framework. 

   default: "0.7.1"

.. data:: framework_name

   The name of the Elasticsearch mesos framework. 

   default: "elasticsearch"

.. data:: framework_ui_port

   The port that the Elasticsearch framework user interface listens on.

   default: 31100

.. data:: framework_use_docker

   The framework will use docker if true, or jar files if false. Using the
   Docker version is unsupported at this time.

   default: false

.. data:: kibana_image

   The name of the Kibana docker image. 

   default: kibana

.. data:: kibana_image_tag

   The tag of the Kibana docker image. 

   default: 4.3.1

.. data:: kibana_build_num

   The Kibana build number. This is necessary to properly create the default
   index pattern during the installation.

   default: 9517
