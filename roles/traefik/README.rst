Traefik
=======

.. versionadded:: 0.5

`Traefik <http://traefik.github.io/>`_ is a modern HTTP reverse proxy and load
balancer made to deploy microservices with ease. It supports several backends
(Docker, Mesos/Marathon, Consul, Etcd, Zookeeper, BoltDB, Rest API, file…) to
manage its configuration automatically and dynamically.

Traefik is used as the only work role on the edge nodes. You should customize
``traefik_marathon_domain`` to set a domain (for example
``apps.yourdomain.com``) and then set an A record for each of the edge servers
to ``*.apps.yourdomain.com``.

Migrating from haproxy
----------------------

In 0.5, this role replaces haproxy. To migrate, set ``traefik_marathon_domain``
to whatever was previously the value of ``haproxy_domain`` and make sure your
customized config has the new role from ``sample.yml``.

Variables
---------

You can use these variables to customize your Traefik installation.

.. data:: traefik_marathon_endpoint

   The endpoint that Marathon talks to. Do not change this unless you are using
   non-default security settings (namely, if you have iptables disabled, this
   could also be set to ``http://marathon.service.consul:8080``)

   default: ``http://marathon.service.consul:18080``

.. data:: traefik_marathon_domain

   The domain that Traefik will match hosts on by default (you can `change this
   on a per-app basis
   <https://github.com/emilevauge/traefik/blob/master/docs/index.md#marathon>`_)

   default: ``marathon.localhost``
