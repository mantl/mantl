.. versionadded:: 0.1

`Marathon <http://mesosphere.github.io/marathon/>`_ is a scheduler for
:doc:`mesos` - it takes specifications for apps to run and lets you
scale them up and down, and deploy new versions or roll back. Like
Mesos' leader mode, Marathon can run on as many servers as you like
and will elect a leader among nodes using :doc:`zookeeper`.

Variables
---------

There are currently no variables for Marathon.

.. _marathon-example-playbook:

Example Playbook
----------------

.. code-block:: yaml+jinja

    ---
    # it would make sense for these servers to be located close to
    # your Mesos leaders, maybe even on the same nodes. They talk back
    # and forth quite a lot.
    - hosts: marathon_servers
      roles:
        - marathon
