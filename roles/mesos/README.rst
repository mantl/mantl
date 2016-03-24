Mesos
=====

.. versionadded:: 0.1

`Mesos <https://mesos.apache.org/>`_ is the distributed system kernel that
manages resources across multiple nodes. When combined with :doc:`marathon`, you
can basically think of it as a distributed init system.

Modes
-----

Marathon can be run in one of two "modes":

 - A server mode (called "master" or "leader")
 - A client mode (called "slave" or "follower")

This project prefers the "leader/follower nomenclature". In addition to the
"official" modes described below, :data:`mesos_mode` supports running both modes
on a single machine for testing or development scenarios.

Leader
^^^^^^

Leaders will communicate with each other via :doc:`zookeeper` to coordinate
which leader controls the cluster. Because of this, you can run as many leader
nodes as you like, but you should consider keeping an odd number in the cluster
to make attaining a quorum easier. A single leader node will also work fine, but
will not be highly available.

Follower
^^^^^^^^

Follower nodes need to know where the leaders are, and there can be any number
of them. You should keep the follower machines free of "heavier" services
running outside Mesos, as this will cause inaccurate resource availability
counts in the cluster.

Upgrading
---------

.. versionadded:: 1.0

If you are running Mantl 0.5.1, you'll need to run the
``playbooks/upgrade-mesos-marathon.yml`` playbook before reprovisioning your
cluster to 1.0. The packaging format changed in the 1.0 release, this will
ensure a smooth upgrade.

Upgrades from releases prior to Mantl 0.5.1 have not been tested.

Variables
---------

You can use these variables to customize your Mesos installation.

.. data:: mesos_mode

   Set to ``leader`` for leader mode, and ``follower`` for follower mode. Set to
   ``mixed`` to run both leader and follower on the same machine (useful for
   development or testing.)

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

.. data:: mesos_resources

   Set resources for follower nodes. (useful for setting available ports that
   applications can be bound to) Format:
   ``name(role):value;name(role):value...``

   default: ``ports(*):[4000-5000, 31000-32000]``

.. data:: mesos_cluster

   default: ``mantl``

.. data:: mesos_zk_dns

   default: ``zookeeper.service.consul``

.. data:: mesos_zk_port

   default: ``2181``

.. data:: mesos_zk_chroot

   default: ``mesos``

.. data:: mesos_credentials

   A list of credentials to add for authentication. These should be in the form
   ``{ principal: "...", secret: "..." }``.

   default: ``[]``

.. data:: mesos_authenticate_frameworks

   Enable Mesos authentication for frameworks. You should set
   :data:`mesos_credentials` for credentials if this is set.

   default: set automatically if framework credentials are present

.. data:: mesos_authenticate_followers

   Enable Mesos authentication from followers. If set, each follower will need
   :data:`mesos_follower_secret` set in their host variables.

   default: set automatically if follower credentials are present

.. data:: mesos_follower_principal

   The principal to use for follower authentication

   default: ``follower``

.. data:: mesos_follower_secret

   The secret to use for follower authentication

   default: not set. Set this to enable follower authentication.

.. data:: mesos_logging_level

   The log level for Mesos. This is set for all components.

   Default: ``WARNING``
