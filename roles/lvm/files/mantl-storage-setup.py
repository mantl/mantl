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


def pvs():
    output = check_output([PVS_CMD, "--noheadings", "-o", "pv_name,vg_name", "--separator", ";"])
    for line in output.splitlines():
        parts = line.strip().split(';')
        if parts[0].startswith("/dev/dm-"):
            parts[0] = find_mapper_device_name(parts[0])
        yield {
            'name': parts[0],
            'vg_name': parts[1],
        }

def vgs():
    output = check_output([VGS_CMD, "--noheadings", "-o",  "vg_name,pv_count,lv_count", "--separator", ";"])
    for line in output.splitlines():
        parts = line.strip().split(';')
        yield {
            'vg_name': parts[0],
            'pv_count': int(parts[1]),
            'lv_count': int(parts[2]),
        }


def lvs(vg, units):
    dp = re.compile(r"(\.|,)")
    output = check_output([LVS_CMD, "--noheadings", "-o", "lv_name,size", "--units", units, "--separator", ";", vg])
    for line in output.splitlines():
        parts = line.strip().split(';')
        yield {
            'lv_name': parts[0],
            'size': int(dp.split(parts[1])[0]),
        }


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
        if each['name'] in dev_list and each['vg_name'] != name:
            fail("Device {} is already in {} volume group.".format(each['name'],each['vg_name']))
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


def process_volume(sec, params):
    lv = params.get(sec, "volume")
    vg = params.get(sec, "group")
    size = params.get(sec, "size")
    force = optional(params.getboolean, sec, "force", False)
    size_opt = 'L'
    size_unit = 'm'

    # FIXME: rewrite due licensing (possible using regexps)
    if size:
        # -l --extents -- option with percentage
        if '%' in size:
            size_parts = size.split('%', 1)
            size_percent = int(size_parts[0])
            if size_percent > 100:
                fail("Size percentage cannot be larger than 100%")
            whole = size_parts[1]
            if size_parts[1] not in ['VG', 'PVS', 'FREE']:
                fail("Specify extents as a percentage of VG|PVS|FREE")
            size_opt = 'l'
            size_unit = ''

        #  -L --size -- option with unit
        elif size[-1].isalpha():
            if size[-1].upper() in 'BSKMGTPE':
                size_unit = size[-1].lower()
                if size[0:-1].isdigit():
                    size = int(size[0:-1])
                else:
                    fail("Bad size specification for unit %s" % size_unit)
                size_opt = 'L'
            else:
                fail("Size unit should be one of [BSKMGTPE]")
        # when no unit, megabytes by default
        elif size.isdigit():
            size = int(size)
        else:
            fail("Bad size specification")
    else:
        fail("size not specified")

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
Before=local-fs.target

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
                f.write(UNIT_TEMPLATE.format(what=dev, where=mount, type=fstype, wanted_by=" ".join(wanted_by),required_by=" ".join(required_by)))
        check_call(["systemctl", "daemon-reload"])
        check_call(["systemctl", "enable", unit])


def iterate_config(prefix, fun, cp):
    for each in cp.sections():
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


    print "ALL DONE!"

if __name__ == '__main__':
    main()
