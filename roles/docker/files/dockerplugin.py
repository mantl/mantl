#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Collectd plugin for collecting docker container stats
#
# Copyright © 2015 eNovance
#
# Authors:
#   Sylvain Baubeau <sylvain.baubeau@enovance.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Requirements: docker-py

import docker
import dateutil.parser
import json
import time
import sys
import os

PREFIX = "container-"

if __name__ != "__main__":
    import collectd
else:
    class ExecCollectdValues:
        def dispatch(self):
            if not getattr(self, "host", ""):
                self.host = os.environ.get("COLLECTD_HOSTNAME", "localhost")
            identifier = "%s/%s" % (self.host, self.plugin)
            if getattr(self, "plugin_instance", ""):
                identifier += "-" + self.plugin_instance
            identifier += "/" + self.type
            if getattr(self, "type_instance", ""):
                identifier += "-" + self.type_instance
            print "PUTVAL", identifier, \
                  ":".join(map(str, [int(self.time)] + self.values))

    class ExecCollectd:
        def Values(self):
            return ExecCollectdValues()

        def warning(self, msg):
            print "WARNING:", msg

        def info(self, msg):
            print "INFO:", msg

    collectd = ExecCollectd()


class DockerClient(docker.Client):
    def stats(self, container):
        u = self._url("/containers/%s/stats" % container["Id"])
        response = self.get(u, stream=True)
        for line in response.iter_lines():
            if line:
                yield json.loads(line)


class Stats:
    @classmethod
    def emit(cls, container, type, value, t="", type_instance=""):
        val = collectd.Values()
        val.plugin = "docker"
        val.plugin_instance = PREFIX + container[:12]
        if type:
            val.type = type
        if type_instance:
            val.type_instance = type_instance
        val.values = value
        if time:
            val.time = time.mktime(dateutil.parser.parse(t).timetuple())
        else:
            val.time = time.time()
        val.dispatch()

    @classmethod
    def read(cls, container, stats):
        raise Exception("NotImplemented")


class BlkioStats(Stats):
    @classmethod
    def read(cls, container, stats, t):
        for key, values in stats.items():
            values = [int(x["value"]) for x in values]
            if len(values) == 5:
                cls.emit(container["Id"], "blkio", values,
                         type_instance=key, t=t)
            elif values:
                # For some reason, some fields contains only one value and the
                # 'op' field is empty. Need to investigate this
                cls.emit(container["Id"], "blkio.single", values,
                         type_instance=key, t=t)


class CpuStats(Stats):
    @classmethod
    def read(cls, container, stats, t):
        cpu_usage = stats["cpu_usage"]
        percpu = cpu_usage["percpu_usage"]
        for cpu, value in enumerate(percpu):
            cls.emit(container["Id"], "cpu.percpu.usage", [value],
                     type_instance="cpu%d" % (cpu,), t=t)

        items = stats["throttling_data"].items()
        items.sort()
        cls.emit(container["Id"], "cpu.throttling_data",
                 [x[1] for x in items], t=t)

        values = [cpu_usage["total_usage"], cpu_usage["usage_in_kernelmode"],
                  cpu_usage["usage_in_usermode"], stats["system_cpu_usage"]]
        cls.emit(container["Id"], "cpu.usage", values, t=t)


class NetworkStats(Stats):
    @classmethod
    def read(cls, container, stats, t):
        items = stats.items()
        items.sort()
        cls.emit(container["Id"], "network.usage", [x[1] for x in items], t=t)


class MemoryStats(Stats):
    @classmethod
    def read(cls, container, stats, t):
        values = [stats["failcnt"], stats["max_usage"], stats["usage"]]
        cls.emit(container["Id"], "memory.usage", values, t=t)

        for key, value in stats["stats"].items():
            cls.emit(container["Id"], "memory.stats", [value],
                     type_instance=key, t=t)


class DockerPlugin:
    CLASSES = {"network": NetworkStats,
               "blkio_stats": BlkioStats,
               "cpu_stats": CpuStats,
               "memory_stats": MemoryStats}
    BASE_URL = 'unix://var/run/docker.sock'

    def configure_callback(self, conf):
        for node in conf.children:
            if node.key == 'BaseURL':
                self.BASE_URL = node.values[0]

    def init_callback(self):
        self.client = DockerClient(base_url=self.BASE_URL)

    def read_callback(self):
        for container in self.client.containers():
            if not container["Status"].startswith("Up"):
                continue
            stats = self.client.stats(container).next()
            t = stats["read"]
            for key, value in stats.items():
                klass = self.CLASSES.get(key)
                if klass:
                    klass.read(container, value, t)


plugin = DockerPlugin()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        plugin.BASE_URL = sys.argv[1]
    plugin.init_callback()
    plugin.read_callback()

else:
    collectd.register_config(plugin.configure_callback)
    collectd.register_init(plugin.init_callback)
    collectd.register_read(plugin.read_callback)
