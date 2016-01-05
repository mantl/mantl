Drone CI Testing Harness
========================

Drone is a CI tool that uses Docker to create isolated build environments, that
can run on a server or locally.

Their main website is `drone.io`_; documentaion is in the `readme`_.

.. _drone.io: https://drone.io
.. _readme: http://readme.drone.io

Main Configuration: .drone.yml
------------------------------

The main configuration for drone is ``.drone.yml``:
.. literalinclude:: ../../.drone.yml

Analysis Build Section
^^^^^^^^^^^^^^^^^^^^^^

The ``analysis`` build section has two primary commands: ``terraform plan``, and ``ansible-lint``.
Terraform's plan command checks the ``.tf`` files for syntax errors, but does not actually provision resources.
The `ansible-lint`_ tool checks the playbooks for common mistakes, such as trailing whitespace.

.. _ansible-lint: https://github.com/willthames/ansible-lint

Provision Build Section
^^^^^^^^^^^^^^^^^^^^^^^

The ``provision`` section runs the integration test script, which requires security credentials. Therefore, on our
servers, it will not run during pull requests.  The integration test script builds up a cluster, provisions it with
ansible, performs health checks and other tests, then destroys the resources created.

Testing Directory
-----------------

The ``testing`` directory contains the configuration and scripts for our testing harness.
There is a tf file for each provider that we have connected to our CI server, and not a full list of providers.
With drone's matrix feature, each tf file is tested in separate docker containers.

There is room for more testing scripts, so please let us know if there is a missing test, or feel free to add your own!

Local Testing
-------------

If you have the cli tools installed, you can run drone tests locally. When you
do that, the secrets file WILL NOT be decrypted, and the integration test will
not run. Comment out or delete the ``when`` key in ``.drone.yml`` under the
``provision`` build step to make sure that you can run the test, and add in
credentials to the ``environment`` section so that terraform will work.

.. warning::

   Drone tests time out after an hour by default, and if a test exits
   before the destroy step, there will be instances left on your providers!
