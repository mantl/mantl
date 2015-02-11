.. versionadded:: 0.1

`Mesos <https://mesos.apache.org/>`_ is the distributed system kernel
that schedules units of work around the cluster. You can basically
think of it as a distributed init system. It has two modes: a server
mode (called "master" or "leader"), and a client mode (called "slave"
or "follower".) This project prefers the "leader/follower"
nomenclature.

Variables
---------

You can use these variables to customize your Mesos installation (see
the :ref:`Mesos Example Playbook <mesos-example-playbook>` for how to
do so.)

.. data:: mesos_mode

   Change this in a configuration to set whether this server (or
   group) is set to be leaders (``leader``) or followers
   (``follower``). Leaders will communicate with :doc:`zookeeper` to
   coordinate which one controls the cluster. You should strongly
   consider running an odd number greater than one, for ease of
   election. Followers do not need to follow this rule, and you can
   have as many as you have servers. If you're running a single-node
   deployment for testing, you can set this value to ``mixed`` to run
   a leader and follower on the same node.

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
