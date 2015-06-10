Logstash
========

Logging role for deploying and managing `Logstash <http://logstash.net>`_ 1.5 with Docker and systemd.

Variables
---------

You can use these variables to customize your Logstash installations:

.. data :: logstash_output_stdout

   A simple output which prints to the STDOUT

   Default: false

.. data :: logstash_input_log4j

   Read events over a TCP socket from a Log4j SocketAppender
   
   Default: false

.. data :: logstsh_log4j_port 

    TCP port

    Default: 4560
