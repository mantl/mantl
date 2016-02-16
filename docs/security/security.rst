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
component vary greatly. For example, projects that utilize HTTP tend to provide
support for SSL and HTTP basic authentication while projects in the Hadoop
ecosystem favor Kerberos

.. note:: At the current time the infrastructure is not suitable for running
          untrusted code or multi-tenant workloads.

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
<http://ansible.com>`__ is the primary provisioning tool with a migration of
cloud provisioning to `Terraform <http://terraform.io>`__ starting in 0.3.

The following security features are implemented or on the roadmap:

- Automate provisioning of SSH key into the cloud host (version 0.1)
- Automate the creation of cloud networks (VPC) (version 0.3)
- Automate creation of network security groups (version 0.3)
- Create sudo administrative users and provide ssh access (version 0.1)
- Update Linux kernel & all packages on the node (version 0.1)
- Automate creation of passwords/SSL certificates `#65
  <https://github.com/CiscoCloud/mantl/issues/65>`__
  (version 0.2)
- Encrypt local secrets using `Ansible Vault
  <http://docs.ansible.com/playbooks_vault.html>`_. This means that the all
  generated tokens, passwords, and SSL keys will be encrypted on the
  provisioning system. (future)

The following items are currently not on the roadmap:

- Setting up LDAP servers
- Setting up a Kerberos environment
- Encrypting server disks for data at rest.

Credential Generation
^^^^^^^^^^^^^^^^^^^^^

A ``security-setup`` script has been created to automate the creation of
credentials. Please refer to `the security-setup documentation
<security_setup.html>`__

Component Security
~~~~~~~~~~~~~~~~~~

This area deals with the securing communication and access on the underlying
components like Consul and Mesos.

As can be seen in the following sections, the components we use provide varying
levels of control. When a component has gaps in security support, we provide a
compensating control.

HTTP authentication/SSL
^^^^^^^^^^^^^^^^^^^^^^^

HTTP traffic to the management systems is managed via an nginx proxy that
provides basic authentication and ssl termination. For example, consul will be
configured to bind to ``127.0.0.1:8500``, and nginx will bind to the eth0 port
8500 and forward traffic to ``localhost``.

The web credentials will be stored in consul and consul-template will be used to
modify the nginx authentication file. The long term roadmap of the project is to
move more configuration into consul and out of Ansible.

The following steps are taken to secure http on infrastructure components using
an nginx proxy (version 0.2):

- Create nginx + consul template docker container (version 0.2)
- Create user/password pairs in consul K/V (using Bcrypt) (version 0.2)
- Consul-template manages the nginx auth file (version 0.2)
- Use generated cert from security script for TLS termination. (version 0.2)
- Create default GET policy to allow unauthenticated reads, basic authentication
  required for POST, PUT, DELETE. (future version)

Consul
^^^^^^

- Consul endpoints are encrypted with Self-signed TLS certificates. A master ACL
  token is created as part of the Ansible installation `#46
  <https://github.com/CiscoCloud/mantl/issues/46>`__
  (version 0.2)
- Disable consul exec (version 0.2)
- The consul API/UI port (8500) is bound to localhost, and an nginx proxy is
  used to authenticate POST/PUT/DELETE requests and act as an TLS endpoint.
  (version 0.2)
- `Verify incoming TLS connections
  <http://www.consul.io/docs/agent/options.html#verify_incoming>`__ (version
  0.2)
- `Verify outgoing TLS connections
  <http://www.consul.io/docs/agent/options.html#verify_outgoing>`__ (version
  0.2)
- Configure an `acl\_datacenter
  <http://www.consul.io/docs/agent/options.html#acl_datacenter>`__ (version 0.2)
- Keep `acl\_down\_policy
  <http://www.consul.io/docs/agent/options.html#acl_down_policy>`__ at
  "extend-cache" (version 0.2)
- Create master ACL token (version 0.2)
- Create ACL token for agents (version 0.2)
- Set default ACL policy to "allow" (version 0.2)
 
Future roadmap items:

- Set `acl_default_policy <http://www.consul.io/docs/agent/options.html#acl_default_policy>`_ to "deny"
   (version 0.3+)
- Create ACL policies on K/V store and service endpoints

Consul template
^^^^^^^^^^^^^^^

Consul template is used to dynamically configure components based on
Consul Key/Value pairs or items in the Consul catalog. Consul-template
supports the following security options:

+------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| Option           | Description                                                                                                                               |
+==================+===========================================================================================================================================+
| ``auth``         | The basic authentication username (and optional password), separated by a colon. There is no default value.                               |
+------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| ``ssl``          | Use HTTPS while talking to Consul. Requires the Consul server to be configured to serve secure connections. The default value is false.   |
+------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| ``ssl-verify``   | Verify certificates when connecting via SSL. This requires the use of ``-ssl``. The default value is true.                                |
+------------------+-------------------------------------------------------------------------------------------------------------------------------------------+
| ``token``        | The Consul API token. There is no default value.                                                                                          |
+------------------+-------------------------------------------------------------------------------------------------------------------------------------------+

Consul template is used across the environment. The following settings
are generally used:

- the ``auth`` parameter is set to a username:password that mirrors the nginx
   proxy configuration
- ``ssl`` is set to true
- ``ssl-verify`` is set to ``false`` if Self-signed certificates are used

Docker
~~~~~~

The project is currently using the default Docker configuration for CentOS.
Docker 1.8 is the minimum version installed.

- ReST HTTP port is disabled

Marathon
~~~~~~~~

Marathon supports both basic http authentication and TLS via the Java keystore,
however we use a different method by placing an authenticating proxy in front of
the instance, using the same credentials as for the Mesos and Consul
administrative accounts.

Marathon does not support Zookeeper authentication, so the zookeeper znode must
have world access.

The following controls will be implemented:

- Bind Marathon to locahost (version 0.2+)
- Place nginx authenticating/SSL proxy in front of Marathon (version 0.2)
- Create a dynamic firewall on each Marathon host that uses consul-template to
  only allow connections from other Marathon nodes. (version 0.2)

References:

- `SSL and Basic Access
  Authentication <https://github.com/mesosphere/marathon/blob/master/docs/docs/ssl-basic-access-authentication.md>`__
- `Support Zookeeper Authentication
  <https://github.com/mesosphere/marathon/issues/1336>`__

Mesos
~~~~~

Support for authentication and encryption is limited to framework authentication
in the current 0.21 and earlier versions of Mesos, but better support for
features like SSL is on the roadmap.

Currently Mesos supports basic CRAM-MD5 authentication, with support for
Kerberos on the roadmap `MESOS-418
<https://issues.apache.org/jira/browse/MESOS-418>`__

`Mesos Authorization
<http://mesos.apache.org/documentation/latest/authorization/>`__ allows control
of the following actions: ``register_frameworks``, ``shutdown_frameworks``,
``run_tasks``. Support for Mesos authorization is still being reviewed.

The following steps are taken to secure mesos if security is enabled:

- On the leader nodes, the ``--authenticate`` flag is set
- On the leader nodes, the ``--authenticate_slaves`` flag is set
- A credential file is created and the ``--credential=/path`` is set on leaders
  and followers (version 0.2)
- Mesos nodes connect to zookeeper with a ``username:password`` (version 0.2)
- Zookeeper ACL created on the /mesos znode: world read, mesos full access
  (version 0.2)

Future security items:

- SSL support for Mesos is scheduled to be included in version 0.23:
- `MESOS-910 <https://issues.apache.org/jira/browse/MESOS-910>`__

`Kerberos support in
Mesos <https://issues.apache.org/jira/browse/MESOS-907>`__ is scheduled
for a future release.

References:

- `Framework Authentication in Apache Mesos 0.15.0
  <http://mesos.apache.org/blog/framework-authentication-in-apache-mesos-0-15-0/>`_

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

- We won't store any restricted data within Zookeeper (under review)
- Implement ACLs and Authentication on the ``/mesos`` znode using user digest.
  (version 0.2)
- Implement ACLs and Authentication on the ``/marathon`` znode using user
  digest. (version 0.3+, pending support for Marathon zk authentication))
- Provide Stunnel encryption for Zookeeper Peer-to-Peer communication (version
   0.3+)
- Develop dynamic firewall using consul template on Zookeeper ports (version
  0.3)
- Update Marathon configuration to use zk user:password (future version)
- Update Mesos configuration to use zk user:password (version 0.2)

References:

- `Setting ACLs & Auth in
  zookeeper <https://ihong5.wordpress.com/2014/07/24/apache-zookeeper-setting-acl-in-zookeeper-client/>`_

Longer-term goals
-----------------

Kerberos
~~~~~~~~

- Integrate Kerberos authentication into supported components: Zookeeper, Mesos,
  HDFS, Kafka, etc.

Application SSL support
~~~~~~~~~~~~~~~~~~~~~~~

Enable developers to secure their applications with SSL.

Phase I: SSL support for wildcard DNS domains.

Phase II: SSL support for custom DNS domains

References:

- `HAProxy SSL termination <https://www.digitalocean.com/community/tutorials/how-to-implement-ssl-termination-with-haproxy-on-ubuntu-14-04>`_
- `Heroku SSL Endpoint <https://devcenter.heroku.com/articles/ssl-endpoint>`_
- `Deis SSL support for custom domains <https://github.com/deis/deis/pull/2911>`_
