# Bare-Metal Mantl

By bare-metal we mean a set of physical computers that
have centos 7 installed on them.

If you are using open-stack, Vmware, or a cloud provider, Mantl.io has terraform scripts for
you. From a Mantl.io perspective, this doc is about setting up the inventory file
by hand and preparing the machines to a state similar to what terraform would have
done.

These scripts were created for set of 8 Intel NUCs. Each had 16GB of RAM
2 hyper threaded cores (I5s and I3s).  3 of them had 500 GB SSDs and 3
have 2 TB HDs.  Your hardware can vary.  Theses systems are 4 times larger
that the AWS systems defined in `terraform/aws.sample.tf` (m3.medium
instances have 1 core and 4GB RAM).  In other words, your machines could
be even smaller than our test system.   In fact, maybe you
have a couple of physical boxes, and then created a few virtual machine vms for the controls
on a couple of laptops. They have also been used on much larger machines.

This document explains how to prepare your machine with the base OS, network
hard drive concerns, creating your inventory and getting ansible ready.

## Setting Up Centos 7

### Thumb Drive Install

There are much more professional ways of creating your instances.  But if you are looking for a solution for a
couple machines at home, perhaps you actually need some tips on how to do it.  The least technical way to do this is
with a thumb drive.

Create a boot Centos 7 http://www.myiphoneadventure.com/os-x/create-a-bootable-centos-usb-drive-with-a-mac-os-x
This can be a bit confusing and I used this as well. http://www.ubuntu.com/download/desktop/create-a-usb-stick-on-mac-os
Mantl.io should start with the current Centos 7 minimum.

During installation you will do the defaults except:

 * manually configure your partitions. ON the Manual partioning page.
   * Remove existing partitions
   * Press the button to automatically partition. This will give you a default set.
   * It will put 50 toward root and the rest in home, change this:
     * These are services machines and shouldn't really have much if in home.
     * You will need to leave unformatted space on the drive for docker. Mantl defaults to 100 Gigs.
     * if you have lots of space leave 50 in home, but you won't need much there. Leave the rest unformatted.
 * turn on your wired internet connection.  It should just be a toggle switch for your device.
 * Once the istall starts it asks for a root password and a first user.
   * Having a `centos` admin user will match what happens in cloud environments.


Once rebooted,
if you forgot to turn on your internet in the install, you can set it up like so
http://www.krizna.com/centos/setup-network-centos-7/ .  It might be easier and more
automated (there for less error prone) to just reinstall and remember to turn on your internet during the install.


### Set up Base Network

#### Chosing a static IP range

I chose 172.16.222.x because its unlikely to overlap with anhy network I might move this cluster too.

#### Give it a static IP and set DNS and Gateway

http://ask.xmodulo.com/configure-static-ip-address-centos7.html

at the command line enter:

    ip addr

You should see somethng like:

    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host
           valid_lft forever preferred_lft forever
    2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
        link/ether b8:ae:ed:71:6c:06 brd ff:ff:ff:ff:ff:ff
        inet 172.16.222.22/24 brd 172.16.222.255 scope global eno1
           valid_lft forever preferred_lft forever
        inet6 fe80::baae:edff:fe71:6c06/64 scope link
           valid_lft forever preferred_lft forever

from this you can see that eno1 is the ethernet device.


edit `/etc/sysconfig/network-scripts/ifcfg-eno1`

You can leave everything that is in there but you need to to change  or add
the following. BOOTPROTO and ONBOOT are probably already there.

    BOOTPROTO="static"
    IPADDR="172.16.222.6"
    GATEWAY="172.16.222.1"
    NETMASK="255.255.255.0"
    DNS1="8.8.8.8"
    DNS2="208.67.222.222"
    NM_CONTROLLED=no
    ONBOOT="yes"

the dns lines are going to have to change once consul is up.

NOTE: in centos 7 /etc/resolv.conf is a generated file.

You could also put the dns lines in /etc/sysconfig/network.

permanently change your host name with

    hostnamectl set-hostname edge22

After saving then finally:

    systemctl restart network


### Create Partion For Docker LVM

 * su
 * parted /dev/sda print
 * fdisk /dev/sda
 * Command: n
 * partion : default
   * please note which partition it is in.  So if its partition 5, eventually you will need to tell mantl /dev/sda5 for the LVM
   * you kinda want all your machines to use the same partition because this partition is entered as a ssytem wide variable.
 * first sector: default
 * last sector: +50G
 * Command: w

 * reboot


don't put a file system on the partion.

Note that I am creating a partion size 50 Gigs, this is for docker.  Just make it consistent across your cluster.

if you have MS-dos partions make it a primary partion or it won't work.

Additionally.  If you hang on TASK "lvm | create volume group" then you will have to apply the patch
https://github.com/ansible/ansible-modules-extras/issues/1504 the file you need to do this to is in
mantl base directory /library/lvg.py


Do all the computers to this point.

## Creating Your Inventory

    [role=control]
    control01 private_ipv4=172.16.222.6 ansible_ssh_host=172.16.222.6
    control02 private_ipv4=172.16.222.7 ansible_ssh_host=172.16.222.7
    control03 private_ipv4=172.16.222.8 ansible_ssh_host=172.16.222.8

    [role=control:vars]
    consul_is_server=true
    lvm_physical_device=/dev/sda3

    [role=worker]
    resource01 private_ipv4=172.16.222.11 ansible_ssh_host=172.16.222.11
    resource02 private_ipv4=172.16.222.12 ansible_ssh_host=172.16.222.12
    resource03 private_ipv4=172.16.222.13 ansible_ssh_host=172.16.222.13

    [role=worker:vars]
    consul_is_server=false
    lvm_physical_device=/dev/sda3

    [role=edge]
    edge01 private_ipv4=172.16.222.16 ansible_ssh_host=172.16.222.16
    edge02 private_ipv4=172.16.222.17 ansible_ssh_host=172.16.222.17

    [role=edge:vars]
    consul_is_server=false
    lvm_physical_device=/dev/sda3

    [dc=dc1]
    control01
    control02
    control03
    resource01
    resource02
    resource03
    edge01
    edge02

I had to add the ansible_ssh_host line to run `playbooks/reboot-hosts.yml`

the private_ipv4 is needed by several roles.

The dc=dc1 group is needed to set `consul_dc_group` in the consul roles. And is specifically usd in this setup in the
dnsmasq role.  Setting this in the inventory file is suggested by how the `vagrant\vagrant-inventory` is set.

Note that dc1 is the default.  If you change the name of the data center in your inventory file
you will need to set consul_dc in your bare-metal.yml file.  I went ahead and put an entry for dc1 in bare-metal.yml
so you know where to change it if you need to.

## Getting Started with Ansible


Add your key to all the machines in your test inventory

    ansible all -i testinventory  -u centos -k -m authorized_key -a "user=centos key=https://github.com/larry-svds.keys"

the -k is needed cause I have to have it ask for a password at this point.

now all commands can happen with out the password and -k option. Test with:

    ansible all -i testinventory -u centos -m ping

### Copy the /etc/host file over

Add the nodes to /etc/hosts

content is:

        127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
        ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
        172.16.222.5 MyMac
        172.16.222.6 control01
        172.16.222.7 control02
        172.16.222.8 control03
        172.16.222.11 resource01
        172.16.222.12 resource02
        172.16.222.13 resource03
        172.16.222.16 edge01
        172.16.222.17 edge02

Copy the /etc/host file over.

    ansible all -i testinventory -u centos --sudo --ask-sudo-pass -m copy -a "src=hosts dest=/etc/hosts"


Might as well set the timezone just for grins.

    ansible all -i testinventory -u centos --sudo --ask-sudo-pass -m command -a "timedatectl set-timezone America/Los_Angeles"


## Create Your bare-metal.yml


`docs/bare-metal.yml` is almost identical to `terraform.samle.yml`

Everything in terraform.samle.yml is in bare-metal.yml  bare-metal.yml has the following in additons.

 * Every section has `provider: bare-metal` in its `vars` section.
 * Under `-hosts: all` in the `vars` section

        # Docker needs to be lvm backed.  This is why we had to break our LVM
        # partitions in the install, and add the lvm_physical_device to the
        # inventory. Note this is setting 80%FREE becasue this isn't going to
        # share LVM with the Glusterfs. These partitions are just for Docker.
        docker_lvm_backed: True
        docker_lvm_data_volume_size: 80%FREE

 *  We gather facts for Edge.. per..

         <   # gather facts so that we can fill in networkInterface = "{{ ansible_default_ipv4['interface'] }}"
         <   # in roles/traefik/templates/traefik.toml.j2
         <   gather_facts: yes
         ---
         >   gather_facts: no


## Run it

Copy your bare-metal.yml file to the microservices-infrastructure base directory and run comamnds from the base directory.

Copy your inventory file to the base directory as well.

Run the security-setup script:

    ./security-setup

It asks for one admin password. At the end of that run there will be a `.securty.yml` file.  It will have the password
you entered and a lot of keys and such that are used in the installs and in the installed software.



    ansible-playbook -u centos -i inventory -e @security.yml bare-metal.yml >& bare-metal/bare-metal.log


In another window tail -f  that log file to follow whats going on.

Once you are done go to the browser and go to the /ui directory of any control node and you should see the mantlui.



