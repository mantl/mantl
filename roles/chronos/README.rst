Chronos
=======

.. versionadded:: 0.1

`Chronos <http://http://mesos.github.io/chronos/>`_ It is a distributed 
and fault-tolerant scheduler that runs on top of Apache Mesos that can 
be used for job orchestration. It supports custom Mesos executors as well 
as the default command executor. 
Thus by default, Chronos executes sh (on most systems bash) scripts.

Chronos listens on port 4400.

Variables
---------

.. data:: chronos_zk_auth

   Zookeeper authentication user and digest (right now disabled due to bug in chronos)

.. data:: chronos_zk_dns

   DNS name of the Zookeeper service to connect to

.. data:: chronos_zk_port

   Port of the Zookeeper service to connect to

.. data:: chronos_zk_chroot

   Root path of the chronos service in the Zookeeper

.. data:: chronos_zk_connect

   Connecton string for the Zookeeper service

.. data:: chronos_zk_mesos_master

   URL of the mesos master leader service in Zookeeper

.. data:: zk_docker_image

   Zookeeper docker container image name

.. data:: chronos_port

   Chronos service port

.. data:: chronos_proxy_port

   Chronos proxy port
