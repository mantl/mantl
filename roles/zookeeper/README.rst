ZooKeeper
=========

.. versionadded:: 0.1

`ZooKeeper <https://zookeeper.apache.org/>`_ is used for coordination among
Mesos and Marathon nodes. Rather than storing things in this service yourself,
you should prefer :doc:`consul`.

Variables
---------

You can use these variables to customize your ZooKepeer installation.

.. data:: zk_id

   The value of ``zk_id`` in the ZooKeeper configuration file. If not provided
   it will be set by the playbook.

.. data:: zookeeper_service

   default: zookeeper

.. data:: zookeeper_env

   default: ``dev``

.. data:: zookeeper_ensemble

   default: ``mantl``

.. data:: zookeeper_container_name

   The name that will be used for the container at runtime. Generated
   automatically from :data:`zookeeper_service`, :data:`zookeeper_env`,
   :data:`zookeeper_ensemble`, and :data:`zk_id` if not set.

.. data:: zookeeper_data_volume

   The name of the data volume to store state in. Generated automatically from
   :data:`zookeeper_env`, :data:`zookeeper_ensemble`, and :data:`zk_id` if not
   set.

.. data:: zookeeper_docker_image

   default: ``asteris/zookeeper``

.. data:: zookeeper_docker_tag

   default: ``latest``

.. data:: zookeeper_docker_ports

   Port arguments, which will be passed directly to docker. Opens TCP 2181,
   2888, and 3888 by default.

   default: ``"-p 2181:2181 -p 2888:2888 -p 3888:3888"``

.. data:: zookeeper_docker_env

   default: ``"/etc/default/{{ zookeeper_service }}"``

.. data:: zookeeper_log_threshold

   Log level for ZooKeeper

   default: ``WARN``
