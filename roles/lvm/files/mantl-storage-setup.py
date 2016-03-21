#!/usr/bin/env python
import subprocess
from ConfigParser import ConfigParser, NoOptionError
import os
import sys
import re
from contextlib import closing

DMSETUP_CMD = "/usr/sbin/dmsetup"
PVS_CMD = "/sbin/pvs"
VGS_CMD = "/sbin/vgs"
LVS_CMD = "/sbin/lvs"
PVCREATE_CMD = "/sbin/pvcreate"
VGCREATE_CMD = "/sbin/vgcreate"
LVCREATE_CMD = "/sbin/lvcreate"
VGEXTEND_CMD = "/sbin/vgextend"
VGREDUCE_CMD = "/sbin/vgreduce"

systemd_units = []

def fail(*a):
    sys.stderr.write("ERROR:" + " ".join(*a))
    sys.exit(1)


def safe_split(s):
    return [each for each in re.compile("\s+").split(s.strip()) if each]


def optional(call, sec, opt, default):
    try:
        return call(sec, opt)
    except NoOptionError:
        return default


def check_output(c, *a, **kw):
    print "READ: ", c
    return subprocess.check_output(c, *a, **kw)


def check_call(c, *a, **kw):
    print "EXEC: ", c
    return subprocess.check_call(c, *a, **kw)


def mapper_device_name(dm_device):
    dm_name = check_output([DMSETUP_CMD, "info",  "-C", "--noheadings",  "-o", "name",  dm_device])
    return "/dev/mapper/{}".format(dm_name.rstrip())

def query_lvm(mod, o="all", extra=None):
    query = [mod, "--nameprefix", "--noheadings", "-o", o, "--separator", ";"]
    if extra:
        query.extend(extra)
    output = check_output(query)
    def chunk(ch):
        k, v = ch.split("=")
        return k.replace("LVM2_", "").lower(), v
    for line in output.splitlines():
        yield dict([chunk(each) for each in line.split(";")])

def pvs():
    for each in query_lvm(PVS_CMD):
        if each["pv_name"].startswith("/dev/dm-"):
            each["pv_name"] = mapper_device_name(each["pv_name"])
        yield each

def vgs():
    return query_lvm(VGS_CMD)


def lvs(vg, units):
    return query_lvm(LVS_CMD, extra=["--units", units, vg])

def process_vg(sec, params):
    name = params.get(sec, "name")
    force = optional(params.getboolean, sec, "force", False)
    pesize = optional(params.getint, sec, "pesize", 4)
    vgoptions = safe_split(optional(params.get, sec, "options", ""))

    # split and check for symlinks
    dev_list = set(map(os.path.realpath, safe_split(params.get(sec, 'devices'))))
    current_devs = set()

    # check for device files
    for test_dev in dev_list:
        if not os.path.exists(test_dev):
            fail("Device not found: {}".format(test_dev))

    # check pv for already used devices
    parsed_pvs = pvs()
    for each in parsed_pvs:
        if each['pv_name'] in dev_list and each['vg_name'] != name:
            fail("Device {} is already in {} volume group.".format(each['pv_name'],each['vg_name']))
        if each['vg_name'] == name:
            current_devs.add(os.path.realpath(each['name']))

    parsed_vgs = vgs()

    this = None
    for test in parsed_vgs:
        if test['vg_name'] == name:
            this = test
            break

    if this:
        devs_to_remove = current_devs - dev_list
        devs_to_add = dev_list - current_devs

        for each in devs_to_add:
            subprocess.check_call([PVCREATE_CMD, each])
            subprocess.check_call([VGEXTEND_CMD, name, each])
        for each in devs_to_remove:
            subprocess.check_call([VGREDUCE_CMD, name, each])

    else:
        subprocess.check_call([VGCREATE_CMD] + vgoptions + ['-s', str(pesize), name] + list(dev_list))

pct_re = re.compile(r'^(\d+)%(PVS|LV|FREE)$')
size_re = re.compile(r'^(\d+)[bskmgtpe]$')
def parse_size(size):
    if size:
        m = pct_re.match(size)
        if m:
            if int(m.group(1)) > 100:
                fail("Size percentage cannot be larger than 100%")
            return size, "l", ""
        m = size_re.match(size.lower())
        if m:
            return int(m.group(1)), "L", m.group(2)
        if size.isdigit():
            return size, "L", "m"
        fail("Bad size specification")
    fail("size not specified")


def process_volume(sec, params):
    lv = params.get(sec, "volume")
    vg = params.get(sec, "group")
    size = params.get(sec, "size")
    force = optional(params.getboolean, sec, "force", False)
    size, size_opt, size_unit = parse_size(size)

    this = None
    for test in lvs(vg, size_opt == 'l' and 'm' or size_unit):
        if test['lv_name'] == lv:
            this = test

    if not this:
        check_call([LVCREATE_CMD, "-n", lv, "-" + size_opt, str(size) + size_unit, vg])
    else:
        print "Volume {} already exists".format(lv)


UNIT_TEMPLATE = """
[Unit]
Before=local-fs.target {before}

[Mount]
What={what}
Where={where}
Type={type}

[Install]
WantedBy=local-fs.target {wanted_by}
RequiredBy={required_by}
"""

def process_fs(sec, params):
    dev =  params.get(sec, "dev")
    if not params.has_option(sec, "fstype"):
        return

    fstype = params.get(sec, "fstype")

    try:
        exist_fs = check_output(["blkid", "-c", "/dev/null", "-o", "value", "-s", "TYPE", dev]).strip()
    except subprocess.CalledProcessError:
        exist_fs = ""

    # FIXME: should we stop, if it contain FS of different type?
    if exist_fs != fstype:
        check_call(["mkfs", "-t", fstype, dev])
    else:
        print "Filesystem {} already formatted".format(dev)

    if params.has_option(sec, "mount"):
        mount = params.get(sec, "mount")
        mountname = mount.lstrip("/").replace("/", "-")
        unit = "{}.mount".format(mountname)
        unitfile = os.path.join("/etc/systemd/system/", unit)

        required_by = safe_split(optional(params.get, sec, "required_by", ""))
        wanted_by = safe_split(optional(params.get, sec, "wanted_by", ""))

        if not os.path.exists(unitfile):
            with closing(open(unitfile, "w")) as f:
                f.write(UNIT_TEMPLATE.format(
                    what=dev,
                    where=mount,
                    type=fstype,
                    wanted_by=" ".join(wanted_by),
                    required_by=" ".join(required_by),
                    before=" ".join(wanted_by+required_by)))
        check_call(["systemctl", "enable", unit])
        check_call(["systemctl", "daemon-reload"])

def write_file(sec, params):
    filename = params.get(sec, "file")
    content = params.get(sec, "content")
    crlf = optional(params.getboolean, sec, "crlf", True)


    if not os.path.exists(filename):
        with closing(open(filename, "w")) as f:
            print "WRITE: " + filename
            f.write(content)
            if crlf:
                f.write("\n")

def iterate_config(prefix, fun, cp):
    for each in sorted(cp.sections()):
        if each.startswith(prefix):
            fun(each, cp)


def main():
    dir = "/etc/mantl/filesystems.d"
    for each in sorted(os.listdir(dir)):
        cp = ConfigParser()
        fn = os.path.join(dir, each)
        print "PROCESSING: " + fn
        cp.read(fn)
        iterate_config("group", process_vg, cp)
        iterate_config("volume", process_volume, cp)
        iterate_config("filesystem", process_fs, cp)
        iterate_config("write", write_file, cp)


    print "ALL DONE!"

if __name__ == '__main__':
    main()
