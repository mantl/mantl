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
| `cpu` | read | amount of time spent by the CPU in various states | `none`|
| `disk` | read | performance statistics for block devices and partitions | `none` |
| `df` | read | file system usage information | `exclude all system and obsure file system types` |
| `interface` | read | network interface throughput, packets/s, errors | `none ` |
| `load` | read | system load | `none ` |
| `memory` | read | physical memory utilization | `none ` |
| `processes` | read | number of processes grouped by state | `none` |
| `swap` | read | amount of memory currently written to swap disk | `none` |
| `uptime` | read | system uptime | `none` |
| `users` | read | counts the number of users currently logged into the system | `none` |
| `network` | write | send metrics to collectd compatible receiver | `Server "localhost" "25826"` |
| `syslog` | write | write collectd logs to system | `LogLevel "err"` |
