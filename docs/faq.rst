FAQs
====

What is the relationship between Mantl and `OpenStack Magnum <https://wiki.openstack.org/wiki/Magnum>`_?
---------------------------------------------------------------------------------------

Mantl and Magnum are currently not integrated. However, the projects could
complement one another. Magnum provides an OpenStack API to instantiate a
containerized environment within an OpenStack cloud. Magnum supports a range
of container clustering implementations and Operating System distributions.
Please refer to the `Magnum wiki <https://wiki.openstack.org/wiki/Magnum>`_
for additional Magnum details.

Mantl is an end-to-end solution for deploying and managing a microservices
infrastructure. Mantl hosts are provisioned to OpenStack and other supported
environments using `Terraform <https://www.terraform.io/>`_. Terraform
configuration files manage OpenStack services such as compute,
block storage, networking, etc. required to instantiate a Mantl host
to an OpenStack cloud. The Terraform `OpenStack Provider
<https://www.terraform.io/docs/providers/openstack/index.html>`_ would need to be
updated since it does not support Magnum. If/when this is accomplished, adding
Magnum support to Mantl should be straightforward.

Can I use Mantl with `Kubernetes <http://kubernetes.io>`_?
----------------------------------------------------------------

Kubernetes is an open source orchestration system for Docker containers.
It handles scheduling onto nodes in a compute cluster and actively manages
workloads to ensure that their state matches the users declared intentions.
Using the concepts of "labels" and "pods", it groups the containers which
make up an application into logical units for management and discovery.

Mantl has integrated both Apache Mesos and Kubernetes into it's container stack.
This integration provides users the freedom to choose the best scheduler for their
workloads promoting greater flexibility and choice.

Containers are great for running stateless applications but what about data/stateful services?
------------------------------------------------------------------------------------------------

The container ecosystem is moving quickly, and durable persistent storage is one area
that has received consistent attention. Mantl currently supports GlusterFS as an
`addon <http://docs.mantl.io/en/latest/components/glusterfs.html>`_ for shared
persistent storage. Even without this software, there are databases and patterns that
can provide reliable and consistent data for various use cases. For example, it is 
possible to run MongoDB, Redis, or Cassandra in a way that provides a consistent distributed quorum.

