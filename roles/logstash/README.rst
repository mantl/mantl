Logstash
========

Logging role for deploying and managing `Logstash <http://logstash.net>`_ 1.5 with Docker and systemd.

Variables
---------

You can use these variables to customize your Logstash installations:

.. data :: logstash_output_stdout

   A simple output which prints to the STDOUT

   Default: false

.. data :: logstash_output_elasticsearch

   Configures an elasticsearch output for the local Logstash agent on all nodes.
   You can set this variable to a dictionary that maps to the `Logstash
   Elasticsearch output
   <https://www.elastic.co/guide/en/logstash/1.5/plugins-outputs-elasticsearch.html>`_
   settings.

   Default: n/a

   Example:

.. code-block:: yaml

   logstash_output_elasticsearch:
     host: "elasticsearch.example.com"
     protocol: "http"

.. data :: logstash_output_kafka

   Configures an elasticsearch output for a Kafka cluster. You can set this
   variable to a dictionary that maps to the `Logstash Kafka output
   <https://www.elastic.co/guide/en/logstash/1.5/plugins-outputs-kafka.html>`_
   settings.

   Default: n/a

   Example:

.. code-block:: yaml

   logstash_output_kafka:
     broker_list: "broker1:port,broker2:port,..."
     topic_id: "logstash"

.. data :: logstash_input_log4j

   Read events over a TCP socket from a Log4j SocketAppender
   
   Default: false

.. data :: logstsh_log4j_port 

    TCP port

    Default: 4560
