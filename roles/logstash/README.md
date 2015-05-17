## Logstash

Logging role for deploying and managing [Logstash](http://logstash.net) 1.5 with Docker and systemd.

## Variables

You can use these variables to customize your Logstash installations:

| var | description | default |
|-----|-------------|---------|
|`logstash_output_stdout`|A simple output which prints to the STDOUT|no|
|`logstash_input_log4j`|Read events over a TCP socket from a Log4j SocketAppender|no|
|`logstash_log4j_port`|TCP port|4560|
|`logstash_output_logentries`|Forward logs to logentries|no|
|`logstash_logentries_token`|Unique token provided by logentries|no|
|`logstash_output_webhdfs`|Store events via WebHDFS using gzip compression|no|
|`logstash_webhdfs_host`|Name node|-|
|`logstash_webhdfs_port`|TCP port|50070|
|`logstash_webhdfs_user`|User name|hdfs|
