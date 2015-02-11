.. versionadded:: 0.1

`Mesos <https://mesos.apache.org/>`_ is the distributed system kernel
that manages resources across multiple nodes. When combined with
:doc:`marathon`, you can basically think of it as a distributed init
system.

Modes
-----

Marathon has two "modes" it can run:

 - A server mode (called "master" or "leader")
 - A client mode (called "slave" or "follower")

This project prefers the "leader/follower nomenclature". In addition
to the "official" modes described below, :data:`mesos_mode` supports
running both modes on a single machine for testing or development
scenarios.

Leader
^^^^^^

Leaders will communicate with each other via :doc:`zookeeper` to
coordinate which leader controls the cluster. Because of this, you can
run as many leader nodes as you like, but you should consider keeping
an odd number in the cluster to make attaining a quorum easier. A
single leader node will also work fine, but will not be highly
available.

Follower
^^^^^^^^

Follower nodes need to know where the leaders are, and there can be
any number of them. You should keep the follower machines free of
"heavier" services running outside Mesos, as this will cause
inaccurate resource availability counts in the cluster.

Variables
---------

You can use these variables to customize your Mesos installation (see
the :ref:`Mesos Example Playbook <mesos-example-playbook>` for how to
do so.)

.. data:: mesos_mode

   Set to ``leader`` for leader mode, and ``follower`` for follower
   mode. Set to ``mixed`` to run both leader and follower on the same
   machine (useful for development or testing.)

   default: ``follower``

.. data:: mesos_log_dir

   default: ``/var/log/mesos``

.. data:: mesos_work_dir

   default: ``/var/run/mesos``

.. data:: mesos_leader_port

   default: ``5050``

.. data:: mesos_follower_port

   default: ``5051``

.. data:: mesos_leader_cmd

   default: ``mesos-master``

.. data:: mesos_follower_cmd

   default: ``mesos-slave``

.. data:: mesos_cluster

   default: ``cluster1``

.. data:: mesos_zk_dns

   default: ``zookeeper.service.consul``

.. data:: mesos_zk_port

   default: ``2181``

.. data:: mesos_zk_chroot

   default: ``mesos``

.. _mesos-example-playbook:

Example Playbook
----------------

.. code-block:: yaml+jinja

    ---
    - hosts: mesos_leaders
      roles: 
        - role: mesos
          mesos_mode: leader
    
    - hosts: mesos_followers
      roles: 
        - role: mesos
          mesos_mode: follower
