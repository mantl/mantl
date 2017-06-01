Docker Swarm
============

.. versionadded:: 1.3

`Docker Swarm <https://www.docker.com/products/docker-swarm/>`_ "provides
native clustering capabilities to turn a group of Docker engines into a single,
virtual Docker Engine."

As Swarm integration with Mesos is experimental, we haven't yet enabled that
feature.

Swarm is shipped as an addon, so please run this role after running the core
playbook (sample.yml or mantl.yml). The addon playbook (addons/docker-swarm.yml)
has to be copied to the project's root directory to be run.

Variables
---------

You can use these variables to customize your Swarm installation.

.. data:: swarm_manager_port

   The port that the swarm managers listen on. This is the port via which you'll
   communicate with the Swarm's Docker daemon, e.g.
   ``sudo docker -H :<swarm-manager-port> info``. Defaults to 4000.

.. data:: swarm_tls

   Use TLS to protect the agents' Docker socket exposed over TCP. It is highly
   recommended that you keep this as its default ``true``. This overrides the
   Docker role's ``docker_tcp_tls`` variable.

   Caution: If you didn't have Docker configured for TCP/TLS before installing
   this addon, this can stop all of your containers! See :docs:`docker`
   for more details.
