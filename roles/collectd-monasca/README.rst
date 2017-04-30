Collectd
========

CollectD-Monasca role for deploying custom build CollectD with:
  1. customized plugin-write_kafka that outputs a single metric per message
  2. custom formatter "Monasca" that builds a JSON appropriate for monasca-persister

Installation
------------

CollectD-Monasca is distributed as an addon for Mantl. After a successful
initial run from your customized ``sample.yml``, install it with
``ansible-playbook -e @security.yml addons/collectd-monasca.yml``.

Variables
---------

This role has the following global settings:

.. data ::  Hostname

   Hostname to append to metrics

   Default: ``{{ inventory_hostname }}``

.. data ::  Interval

   Global interval for sampling and sending metrics

   Default: ``10 seconds``

This role enables the following Collectd plugins and settings:

.. data ::  cpu

   Type: read
   Description: amount of time spent by the CPU in various states

.. data ::  disk

   Type: read
   Description: performance statistics for block devices and partitions

.. data ::  df

   Type: read
   Description : file system usage information
   Default: exclude all system and obsure file system types

.. data ::  interface

   Type: read
   Description: network interface throughput, packets/s, errors
.. data ::  load

   Type: read
   Description: system load
.. data ::  memory

   Type: read
   Description: physical memory utilization
.. data ::  network

   Type: write
   Description: send metrics to collectd compatible receiver
   Default: ``Server "localhost" "25826"``
.. data ::  syslog

   Type: write
   Description: write collectd logs to syslog
   Default: ``LogLevel "err"``
.. data ::  write_kafka

   Type: write
   Description: send metrics to Kafka topic
   Default: ``Brokers "broker-1.service.consul:9092,broker-2.service.consul:9092,broker-3.service.consul:9092"``
   Default: ``Topic "metrics"``
