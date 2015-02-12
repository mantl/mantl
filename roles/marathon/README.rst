.. versionadded:: 0.1

`Marathon <http://mesosphere.github.io/marathon/>`_ is a scheduler for
:doc:`mesos` - it takes specifications for apps to run and lets you
scale them up and down, and deploy new versions or roll back. Like
Mesos' leader mode, Marathon can run on as many servers as you like
and will elect a leader among nodes using :doc:`zookeeper`.

Keep Marathon servers close to Mesos leaders for best performance;
they talk back and forth quite a lot to keep the services in the
cluster in a good state. Placing them on the same machines would work.

Variables
---------

There are currently no variables for Marathon.

.. _marathon-example-playbook:

Example Playbook
----------------

.. code-block:: yaml+jinja

    ---
    - hosts: marathon_servers
      roles:
        - marathon
