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
successful initial run (from your customized ``terraform.sample.yml``), install
it with ``ansible-playbook -e @security.yml addons/elk.yml``.

Accessing User Interfaces
-------------------------

After the Elasticsearch framework and the Kibana application have been
successfully installed and initialized, it should be possible to access their
corresponding user interfaces directly from Mantl UI.

Configuration
-------------

The default configuration of the ELK stack will require at least 4 nodes, each
having at least 1 full CPU and 1 GB of memory available to Mesos. In addition,
each node will need to have at least 5 GBs of free disk space.

While a cluster of this size will be sufficient to evaluate and test the ELK
stack on Mantl, we encourage you to review the configuration options below to
size the cluster as appropriate for your environment.

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
