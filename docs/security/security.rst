Security
========

Overview
--------

Our goal is to make it easy to:

-  Encrypt restricted and confidential information in transit
-  Control access to resources
-  Collect and monitor security-related events
-  Manage security policies, credentials and certificates

Because we are working with different projects, the controls implemented in each
component vary greatly.

.. note:: Mantl is not currently suitable for running untrusted code or
   multi-tenant workloads.

Focus Areas
-----------

The security model focuses on three areas:

- Provisioning (Ansible, Terraform)
- Securing system level components (Consul, Mesos, Marathon, etc.)
- Securing Applications that run on the platform

The next sections will deal with each area.

Provisioning
~~~~~~~~~~~~

.. note:: SSH strict host key checking is turned off for now to make development
          against the project easier. When you set up a production instance of
          the project, you should change ``host_key_checking`` and
          ``record_host_keys`` in ``ansible.cfg``

Provisioning security involves setting up a secure cloud environment, basic
server security, and securing secrets on the provisioning systems. `Ansible
<https://www.ansible.com>`__ and `Terraform <https://www.terraform.io>`__ are
our primary provisioning tools.

The following security features are implemented or on the roadmap:

- Automate provisioning of SSH key into the cloud host (version 0.1)
- Automate the creation of cloud networks (VPC) (version 0.3)
- Automate creation of network security groups (version 0.3)
- Create sudo administrative users and provide ssh access (version 0.1)
- Update Linux kernel & all packages on the node (version 0.1)
- Automate creation of passwords/SSL certificates `#65
  <https://github.com/CiscoCloud/mantl/issues/65>`__
  (version 0.2)
- Restrict memory usage of system Docker containers (version 1.2)
- Create unified TLS certificates for each node (version 1.3)
- Always verify every component's API with its TLS certificate (ongoing)
- Auto-rotate TLS certificates (future)
- Store secrets in Vault (future)
- Provide scheduler integration with Vault (future)

The following items are currently not on the roadmap:

- Setting up LDAP servers
- Setting up a Kerberos environment
- Encrypting server disks for data at rest.

Credential Generation
^^^^^^^^^^^^^^^^^^^^^

The ``security-setup`` script has been created to automate the creation of
credentials. Please refer to :doc:`security_setup` documentation.

Component Security
~~~~~~~~~~~~~~~~~~

This area deals with the securing communication and access on the underlying
components like Consul and Mesos.

HTTP authentication, and SSL/TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

HTTP traffic to the management systems is managed via an nginx proxy that
provides basic authentication and SSL termination. For example, Consul binds to
``localhost:8500``, and Nginx will bind to port 8500 on the network interface
and forward traffic to ``localhost``.

The web credentials are stored in the Consul K/V, and Consul-template is used to
modify the Nginx authentication file. The long term roadmap of the project is to
move more configuration into Consul and Vault, and out of our provisioning systems.

Consul
^^^^^^

Consul endpoints are secured with TLS certificates, and all incoming and outgoing
connections are verified with TLS. Consul exec is disabled for security reasons.
The default ACL policy is ``deny``.

Consul Template
^^^^^^^^^^^^^^^

Consul Template is used to dynamically configure components based on Consul K/V
pairs. Consul Template is used across the environment. Consul Template is
configured with TLS, and verifies all connections.

Docker
~~~~~~

The daemon is not exposed to TCP by default, but can be configured to do so,
while verifying incoming requests with TLS.

.. warning:: Never expose the Docker daemon to network traffic without securing
   it with TLS.

Marathon
~~~~~~~~

Marathon supports both basic HTTP authentication and TLS. We place an
authenticating proxy in front of the instance, using the same credentials as for
the Mesos and Consul administrative accounts.

Marathon does not support Zookeeper authentication, so the Zookeeper znode must
have world access. We expect this will change soon.

References:
- `SSL and Basic Access
  Authentication <https://github.com/Mesosphere/marathon/blob/master/docs/docs/ssl-basic-access-authentication.md>`__
- `Support Zookeeper Authentication
  <https://github.com/Mesosphere/marathon/issues/1336>`__

Mesos
~~~~~

We currently support Mesos framework authorization, and will support SSL in the
future (issue #1109).

`Mesos Authorization
<http://Mesos.apache.org/documentation/latest/authorization/>`__ allows control
of the following actions: ``register_frameworks``, ``shutdown_frameworks``,
``run_tasks``. Support for Mesos authorization is still being reviewed.

The following steps are taken to secure Mesos if security is enabled:

- On the leader nodes, the ``--authenticate`` flag is set
- On the leader nodes, the ``--authenticate_slaves`` flag is set
- A credential file is created and the ``--credential=/path`` is set on leaders
  and followers (version 0.2)
- Mesos nodes connect to zookeeper with a ``username:password`` (version 0.2)
- Zookeeper ACL created on the /Mesos znode: world read, Mesos full access
  (version 0.2)

References:

- `Framework Authentication in Apache Mesos 0.15.0
  <http://Mesos.apache.org/blog/framework-authentication-in-apache-Mesos-0-15-0/>`_

Zookeeper
~~~~~~~~~

The main recommendation for securing Zookeeper is to use Kerberos, which
is currently out of scope for the project.

Zookeeper supports `ACLs
<http://zookeeper.apache.org/doc/r3.1.2/zookeeperProgrammers.html#sc_ZooKeeperAccessControl>`__
on Znodes, but ACLs are not recursive.

SSL endpoints are supported via Netty, but the C client does not yet have SSL
support `ZOOKEEPER-2125
<https://issues.apache.org/jira/browse/ZOOKEEPER-2125>`__ `ZOOKEEPER-2122
<https://issues.apache.org/jira/browse/ZOOKEEPER-2122>`__.

Compensating controls:

- We don't store any restricted data within Zookeeper
- Implement ACLs and Authentication on the ``/Mesos`` znode using user digest.
  (version 0.2)
- Implement ACLs and Authentication on the ``/marathon`` znode using user
  digest. (version 0.3+, pending support for Marathon zk authentication))
- Provide Stunnel encryption for Zookeeper Peer-to-Peer communication (version
   0.3+)
- Develop dynamic firewall using Consul Template on Zookeeper ports (version
  0.3)
- Update Marathon configuration to use zk user:password (future version)
- Update Mesos configuration to use zk user:password (version 0.2)

References:

- `Setting ACLs & Auth in
  zookeeper <https://ihong5.wordpress.com/2014/07/24/apache-zookeeper-setting-acl-in-zookeeper-client/>`_

Longer-term goals
-----------------

Application SSL support
~~~~~~~~~~~~~~~~~~~~~~~

Enable developers to secure their applications with SSL.

Phase I: SSL support for wildcard DNS domains.

Phase II: SSL support for custom DNS domains
