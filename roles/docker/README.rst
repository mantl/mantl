Docker
======

.. versionadded:: 0.1

`Docker <https://www.docker.com/>`_ is a container manager and scheduler. In
their words, it "allows you to package an application with all of its
dependencies into a standardized unit for software development." Their site has
`more on what Docker is <https://www.docker.com/whatisdocker>`_. We use it in
microservices-infrastructure to ship units of work around the cluster, combined
with :doc:`marathon`'s scheduling.
