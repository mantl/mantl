## Logstash

Logging role for deploying and managing [Logstash](http://logstash.net) 1.5 with Docker and systemd.

Containers with Logstash are started on each host and collect logs from multiple inputs.
This allows us to filter the logs and send them to a central location. At this time, we support
several outputs such as HDFS and [Logentries](https://logentries.com/). Though, by default all
logs are sent to STDOUT as the HDFS role is still under active development.

## Variables

You can use these variables to customize your Logstash installations:

| var | description | default | port mapping |
|-----|-------------|---------|--------------|
|`logstash_input_log4j`|Read events over a TCP socket from a Log4j SocketAppender|yes|4560|
|`logstash_input_docker`|Read Docker containers JSON type logs|yes|-|
|`logstash_input_mesos`|Read Mesos logs|yes|-|
|`logstash_input_syslog`|Read RFC3164 syslog messages|yes|5514|
|`logstash_input_collectd`|Read events from the collectd binary protocol|yes|25826|
|`logstash_input_statsd`|Read events from StatsD clients|yes|8125|
|`logstash_output_stdout`|A simple output which prints to the STDOUT|yes|-|
|`logstash_output_webhdfs`|Store events via WebHDFS using gzip compression|no|50070|
|`logstash_output_logentries`|Forward logs to logentries|no|-|
|`logstash_logentries_token`|Unique token provided by logentries|no|-|
