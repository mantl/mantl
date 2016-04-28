Docker
======

.. versionadded:: 0.1

`Docker <https://www.docker.com/>`_ is a container manager and scheduler. In
their words, it "allows you to package an application with all of its
dependencies into a standardized unit for software development." Their site has
`more on what Docker is <https://www.docker.com/what-docker>`_. We use it in
Mantl to ship units of work around the cluster, combined
with :doc:`marathon`'s scheduling.

Variables
---------

.. data :: docker_source

  Specify origin of docker packages.

  Possible values:  ``docker``, ``redhat``.

  Default: ``docker` -- using packages from ``Docker, inc``.

Using a private Docker registry
-------------------------------

In addition to the open, official Docker registry at https://hub.docker.com,
one can use a private in-house docker registry for storing and pulling images.
Docker Hub also supports storing private images.

One must configure credentials in order to use private repositories. This is
done with the security-setup script, run it with the flag
``--use-private-docker-registry=true``. It will then ask you for username,
password and e-mail address for the registry user. You can also specify a custom
URL for an in-house Docker registry, or omit it, in which case it will default
to the official registry, https://index.docker.io/v1/.

In addition to configuring access to the specified private docker registries,
this will also create an archive that can be used to supply credentials to
Marathon tasks that require access to those registries. You can specify the path
to the generated credentials archive in the ``uris`` key of your Marathon app
definition:

.. code-block:: json

    ...
    "uris": [
      "file:///etc/docker.tar.gz"
    ],
    ...

See the `Marathon documentation
<https://mesosphere.github.io/marathon/docs/native-docker-private-registry.html>`_
for more information.
