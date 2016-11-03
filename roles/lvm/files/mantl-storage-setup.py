#!/usr/bin/env python
import subprocess
from ConfigParser import ConfigParser, NoOptionError
import os
import time
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
LVCONVERT_CMD = "/sbin/lvconvert"

systemd_units = []

def fail(*a):
    sys.stderr.write("ERROR:" + " ".join(a) + "\n")
    sys.exit(1)


def safe_split(s):
    return filter(None, re.compile("\s+").split(s.strip()))


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
    query = [mod, "--nameprefix", "--noheadings", "--unquoted", "-o", o, "--separator", ";"]
    if extra:
        query.extend(extra)
    output = check_output(query)
    def chunk(ch):
        k, v = ch.split("=")
        return k.replace("LVM2_", "").lower(), v.strip()
    for line in output.splitlines():
        yield dict([chunk(each) for each in line.split(";")])


def lvm_profile_dir():
    return check_output(["lvm", "config", "config/profile_dir"]).splitlines()[0].split("=")[1].replace('"', "")

def pvs():
    for each in query_lvm(PVS_CMD, o="pv_all,vg_name"):
        if each["pv_name"].startswith("/dev/dm-"):
            each["pv_name"] = mapper_device_name(each["pv_name"])
        yield each

def vgs():
    return query_lvm(VGS_CMD)

def free_space(vg, units):
    return int(find_this(query_lvm(VGS_CMD, extra=["--nosuffix", "--units", units, vg]), "vg_name", vg)["vg_free"])

def lvs(vg, units):
    return query_lvm(LVS_CMD, extra=["--units", units, vg])

def find_this(lst, key, val):
    for each in lst:
        if each[key] == val:
            return each

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
    for each in pvs():
        if each['pv_name'] in dev_list and each['vg_name'] != name:
            fail("Device {} is already in {} volume group.".format(each['pv_name'],each['vg_name']))
        if each['vg_name'] == name:
            current_devs.add(os.path.realpath(each['pv_name']))

    this = find_this(vgs(), "vg_name", name)

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

pct_re = re.compile(r'^(\d+)%(PVS|VG|FREE)$')
size_re = re.compile(r'^(\d+)([bskmgtpe])b?$')
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


def wait_for_device(dev):
    print "--> Wait for device {}".format(dev)
    for sec in range(0, 60):
        if os.path.exists(dev):
            print "--> Device {} appears in {} seconds".format(dev, sec)
            break
        time.sleep(1)


def process_volume(sec, params):
    lv = params.get(sec, "volume")
    vg = params.get(sec, "group")
    size = params.get(sec, "size")
    force = optional(params.getboolean, sec, "force", False)
    size, size_opt, size_unit = parse_size(size)

    this = find_this(lvs(vg, size_opt == 'l' and 'm' or size_unit), "lv_name", lv)

    if not this:
        print "--> Create volume {}".format(lv)
        check_call([LVCREATE_CMD, "-n", lv, "-" + size_opt, str(size) + size_unit, vg])
    else:
        print "--> Do nothing. Volume {} already exists".format(lv)


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

    wait_for_device(dev)
    try:
        exist_fs = check_output(["blkid", "-c", "/dev/null", "-o", "value", "-s", "TYPE", dev]).strip()
    except subprocess.CalledProcessError:
        exist_fs = ""

    # FIXME: should we stop, if it contain FS of different type?
    if exist_fs != fstype:
        print "--> Formatting filesystem {} with {}".format(dev, fstype)
        check_call(["mkfs", "-t", fstype, dev])
    else:
        print "--> Do nothing. Filesystem {} already formatted".format(dev)

    if params.has_option(sec, "mount"):
        print "--> Create mount for {}".format(dev)
        mount = params.get(sec, "mount")
        mountname = mount.lstrip("/").replace("/", "-")
        unit = "{}.mount".format(mountname)
        unitfile = os.path.join("/etc/systemd/system/", unit)

        required_by = safe_split(optional(params.get, sec, "required_by", ""))
        wanted_by = safe_split(optional(params.get, sec, "wanted_by", ""))

        if not os.path.exists(unitfile):
            with closing(open(unitfile, "w")) as f:
                print "--> Writing {}".format(unitfile)
                f.write(UNIT_TEMPLATE.format(
                    what=dev,
                    where=mount,
                    type=fstype,
                    wanted_by=" ".join(wanted_by),
                    required_by=" ".join(required_by),
                    before=" ".join(wanted_by+required_by)))
        else:
            print "--> Not writing {}, it already exists".format(unitfile)
        check_call(["systemctl", "enable", unit])
        check_call(["systemctl", "daemon-reload"])
    else:
        print "--> Not mounting {}".format(dev)

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

def process_thin(sec, params):
    pool = params.get(sec, "pool")
    meta = optional(params.get, sec, "meta", "{}-meta".format(pool))
    data = optional(params.get, sec, "data", pool)
    chunk_size = optional(params.get, sec, "chunk_size", None)
    extra = optional(params.get, sec, "extra_docker_params", "")
    vg = params.get(sec, "group")
    size = params.get(sec, "size")
    size, size_opt, size_unit = parse_size(size)

    this = find_this(lvs(vg, size_opt == 'l' and 'm' or size_unit), "lv_name", pool)
    if this:
        if not "thin" in this['lv_layout']:
            fail("Volume {} exists, and it not thin pool".format(pool))
        print "--> Volume {} already created".format(pool)
    else:

        meta_size = free_space(vg, "s") / 1000 + 1
        print "--> Create meta volume {} for thin pool".format(meta)
        check_call([LVCREATE_CMD, "-n", meta, "-L",  str(meta_size) + "s", vg])
        print "--> Create data volume {} for thin pool".format(data)
        check_call([LVCREATE_CMD, "-n", data, "-" + size_opt, str(size) + size_unit, vg])
        print "--> Create thin pool {}".format(pool)
        convert = [LVCONVERT_CMD, "-y", "--zero", "n" ]
        if chunk_size:
            convert.extend(["-c", chunk_size])
        convert.extend(["--thinpool", "{}/{}".format(vg, data), "--poolmetadata", "{}/{}".format(vg, meta)])
        check_call(convert)

    # re-read lvs after all
    this = find_this(lvs(vg, size_opt == 'l' and 'm' or size_unit), "lv_name", pool)
    dm_name = "/sys/dev/block/{lv_kernel_major}:{lv_kernel_minor}/dm/name".format(**this)
    with closing(open(dm_name, "r")) as f:
        mapper_device = f.readline().strip()
    
    DOCKER_STORAGE_CONF = "/etc/sysconfig/mantl-storage"
    conf = optional(params.get, sec, "config", DOCKER_STORAGE_CONF)
    print "--> Write {}".format(conf)
    with closing(open(conf, "w")) as f:
        f.write("""MANTL_STORAGE_OPTIONS=--storage-driver devicemapper --storage-opt dm.thinpooldev=/dev/mapper/{mapper} {extra}""".format(mapper=mapper_device, extra=extra))
    check_call(["systemctl", "daemon-reload"])



def iterate_config(prefix, fun, cp):
    for each in sorted(cp.sections()):
        if each.startswith(prefix):
            fun(each, cp)


def main():
    dir = "/etc/mantl/filesystems.d"
    for each in sorted(os.listdir(dir)):
        cp = ConfigParser()
        fn = os.path.join(dir, each)
        print "==> Processing: " + fn
        cp.read(fn)
        iterate_config("group", process_vg, cp)
        iterate_config("thin", process_thin, cp)
        iterate_config("volume", process_volume, cp)
        iterate_config("filesystem", process_fs, cp)
        iterate_config("write", write_file, cp)

    print "==> ALL DONE!"

if __name__ == '__main__':
    main()
