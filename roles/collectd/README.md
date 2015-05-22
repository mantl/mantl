# Collectd

Collectd role for deploying Collectd.

This role has the following global settings:

| setting | description | value |
|-----|-------------|---------|
| `Hostname` | Hostname to append to metrics | `{{ ansible_hostname }}` |
| `Interval` | Global interval for sampling and sending metrics | `10 seconds` |

This role enables the following Collectd plugins and settings:

| plugin | type | description | setting |
|-----|----|-------------|---------|
| `cpu` | read | amount of time spent by the CPU in various states | |
| `disk` | read | performance statistics for block devices and partitions | |
| `df` | read | file system usage information | exclude all system and obsure file system types |
| `interface` | read | network interface throughput, packets/s, errors | |
| `load` | read | system load | |
| `memory` | read | physical memory utilization | |
| `processes` | read | number of processes grouped by state | |
| `swap` | read | amount of memory currently written to swap disk | |
| `uptime` | read | system uptime | |
| `users` | read | counts the number of users currently logged into the system | |
| `network` | write | send metrics to collectd compatible receiver | `Server "localhost" "25826"` |
| `syslog` | write | write collectd logs to syslog | `LogLevel "err"` |
