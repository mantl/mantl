Elasticsearch
=========

.. versionadded:: 1.0

This playbook installs the Elasticsearch framework. It also configures Logstash on all nodes to forward logs to that cluster.

Installation
------------

As of 1.0, Elasticsearch is distributed as an addon for Mantl. After a
successful initial run (from your customized ``terraform.sample.yml``), install
it with ``ansible-playbook -e @security.yml addons/elasticsearch.yml``.

Variables
---------


