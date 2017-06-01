Traefik
=======

.. versionadded:: 0.5

`Traefik <https://traefik.io/>`_ is a modern HTTP reverse proxy and load
balancer made to deploy microservices with ease. It supports several backends
(Docker, Mesos/Marathon, Consul, Etcd, Zookeeper, BoltDB, Rest API, file…) to
manage its configuration automatically and dynamically.

Traefik is used as the only work role on the edge nodes. You should customize
``traefik_marathon_domain`` to set a domain (for example
``apps.yourdomain.com``) and then set an A record for each of the edge servers
to ``*.apps.yourdomain.com``.



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
   <http://traefik.readthedocs.org/en/latest/backends/#marathon-backend>`_)

   default: ``marathon.localhost``

.. data:: traefik_marathon_expose_by_default

   Automatically expose Marathon applications in traefik.

   The traefik default is ``false``, or not forward traffic.
  
   The mantl default is set to ``true``.
 
