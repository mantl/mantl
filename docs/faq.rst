FAQs
====

How does Mantl compare to `OpenStack Magnum <http://wiki.openstack.org/wiki/Magnum>`_?
--------------------------------------------------------------------------------------

Mantl and Magnum are currently not integrated. However, the projects could
compliment one other. Magnum provides an OpenStack API to instantiate a
containerized environment within an OpenStack cloud. Magnum supports a range
of container clustering implementations and Operating System distributions.
Please refer to the `Magnum wiki <http://wiki.openstack.org/wiki/Magnum>`_
for additional Magnum details.

Mantl is an end-to-end solution for deploying and managing a microservices
infrastructure. Mantl hosts are provisioned to OpenStack and other supported
environments using `Terraform <https://www.terraform.io/>`_. Terraform
configuration files manage OpenStack services such as compute,
block storage, networking, etc. required to instantiate a Mantl host
to an OpenStack cloud. The Terraform `OpenStack Provider`_ would need to be
updated since it does not support Magnum. If/when this is accomplished, adding
Magnum support to Mantl should be simple.

How does Mantl compare to `Kubernetes <http://kubernetes.io/>`_?
----------------------------------------------------------------

Kubernetes is an open source orchestration system for Docker containers.
It handles scheduling onto nodes in a compute cluster and actively manages
workloads to ensure that their state matches the users declared intentions.
Using the concepts of "labels" and "pods", it groups the containers which
make up an application into logical units for easy management and discovery.

Mantl is an end-to-end solution for deploying and managing a microservices
infrastructure. Mantl currently uses `Apache Mesos <http://mesos.apache.org/>`_
as a cluster manager for microservices. The Mantl team is in the process of
evaluating Kubernetes as a cluster manager.

.. _OpenStack Provider : https://www.terraform.io/docs/providers/openstack/index.html
