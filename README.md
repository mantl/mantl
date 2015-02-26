Overview
--------
Microservices infrastructure is a powerful platform for rapidly deploying containers any analytic applications.

##Features

* Docker Container support
* Mesos, Marathon and Zookeeper
* Consul DNS-based service discovery 
* High Availability
* Multi-Datacenter support
* Vagrantfile for testing

####Architecture
The base platform contains control nodes that manage the cluster and any number of compute nodes. Containers automatically register themselves into DNS so that other services can locate them.

![Single-DC](docs/_static/single_dc.png =480x)

Once WAN joining is configured, each cluster find services in other data centers via DNS or the [Consul API](http://www.consul.io/docs/agent/http.html). 

![Mult-DC](docs/_static/multi_dc.png =480x)

####Control Nodes

The compute node manages a single datacenter.  Each control node runs Consul for service discovery, Mesos leaders for resource scheduling and Mesos frameworks like Marathon. 

In general, it's best to provision 3 or 5 control nodes to achieve higher availability of services.

![Control Node](docs/_static/control_node.png =480x)

####Compute Nodes

The compute node launches containers and other Mesos-based workloads. Registrator is used to update Consul as containers are launched and exit. 

![Compute Node](docs/_static/compute_node.png =480x)








##Getting Started

[Getting Started Documentation](https://microservices-infrastructure.readthedocs.org/en/latest/getting_started/index.html)


##Documentation
All documentation is located at [https://microservices-infrastructure.readthedocs.org](https://microservices-infrastructure.readthedocs.org/en/latest). 

To build the documentation locally, run:

```
	sudo pip install -r requirements.txt
	cd docs
	make html

```

License
-------
Copyright ©2015 Cisco Systems, Inc. All rights reserved. 

Released under the Apache 2.0 License. See LICENSE.