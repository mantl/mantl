Marathon
========

.. versionadded:: 0.1

`Marathon <http://mesosphere.github.io/marathon/>`_ is a scheduler for
:doc:`mesos` - it takes specifications for apps to run and lets you scale them
up and down, and deploy new versions or roll back. Like Mesos' leader mode,
Marathon can run on as many servers as you like and will elect a leader among
nodes using :doc:`zookeeper`.

Keep Marathon servers close to Mesos leaders for best performance; they talk
back and forth quite a lot to keep the services in the cluster in a good state.
Placing them on the same machines would work.

Marathon listens on port 8080. To connect to Marathon securely, set
:data:`marathon_keystore_path` and :data:`marathon_keystore_password`, then
connect via HTTPS on port 8443.

The Marathon role also sets up `mesos-consul
<https://github.com/CiscoCloud/mesos-consul>`_ and `marathon-consul
<https://github.com/CiscoCloud/marathon-consul>`_ for service discovery.

Variables
---------

.. data:: marathon_http_credentials

   HTTP Basic authentication credentials, in the form "user:password".

.. data:: marathon_keystore_path

   Path on the local machine that contains a Java keystore. Marathon has docs on
   `generating this file
   <https://mesosphere.github.io/marathon/docs/ssl-basic-access-authentication.html>`_.
   Please note that if this option is set, :data:`marathon_keystore_password` is
   *required*.

.. data:: marathon_keystore_password

   Password for the keystore specified in :data:`marathon_keystore_path`.

.. data:: marathon_principal

   Principal to use for Mesos framework authentication.

   .. note:: If you plan to use framework authentication, be sure to add the
             principal and secret to :data:`mesos_credentials` and set
             :data:`mesos_authenticate_frameworks` to ``yes``.

   default: ``marathon``

.. data:: marathon_secret

   Secret to use for Mesos framework authentication. Authentication will only be
   enabled if this value is set to a non-blank value. See also the note in
   :data:`marathon_principal`.

   default: ``""``

.. data:: mesos_consul_image

   Image for the `mesos-consul <https://github.com/CiscoCloud/mesos-consul>`_
   bridge.

   Default: ``drifting/mesos-consul``

.. data:: mesos_consul_image_tag

   Tag for the `mesos-consul <https://github.com/CiscoCloud/mesos-consul>`_
   bridge

   Default: ``latest``

.. data:: marathon_consul_image

   Image for the `marathon-consul
   <https://github.com/CiscoCloud/marathon-consul>`_ bridge.

   Default: ``brianhicks/marathon-consul``

.. data:: marathon_consul_image_tag

   Tag for the `marathon-consul
   <https://github.com/CiscoCloud/marathon-consul>`_ bridge

   Default: ``latest``

.. data:: marathon_logging_level

   Log level for Marathon

   Default: ``warn``
