# Bare-Metal Mantl

By bare-metal we mean a set of physical computers that
have centos 7 installed on them.

If you are using open-stack, Vmware, or some other cloud provider, Mantl.io has terraform scripts for
you. From a Mantl.io perspective, this doc is about setting up the inventory file
by hand and preparing the machines to a state similar to what terraform would have
done.

The minimum requirement for installing mantl based on the AWS sample are edge, control and worker nodes with
1 core and 4 GB of RAM.  If you are building a bare-metal system you will almost certainly have much more than
that.  It should be pointed out this documentation is really a description of how to set up a static inventory
file when you don't create your inventory with Terraform.   In other words, maybe you
have a couple of physical boxes, and then created a few virtual machine vms for the controls
on a couple of laptops. There is nothing about this document that requires that they be physical systems.  This
document does address challenges that people creating a cluster with physical systems face.

This document explains:
 * Preparing your machines with Centos
 * Network and storage concerns
 * Creating your inventory
 * Setting up Ansible

## Setting Up Centos 7

### Thumb Drive Install

There are much more professional ways of creating your instances, but if you are looking for a solution for a
couple machines at home, perhaps you actually need some tips on how to do it.  The least technical way to do this is
with a thumb drive.

Create a boot Centos 7 http://www.myiphoneadventure.com/os-x/create-a-bootable-centos-usb-drive-with-a-mac-os-x
This can be a bit confusing and I used this as well. http://www.ubuntu.com/download/desktop/create-a-usb-stick-on-mac-os
Mantl.io should start with the current Centos 7 minimum.

During installation you will do the defaults except:

 * manually configure your partitions. ON the Manual partioning page:
   * Remove existing partitions
   * Press the button to automatically partition. This will give you a default set to start with.
   * The automatic partioning will put 50 toward root and the rest in home, change this:
     * These are services machines and won't store many files in home, Home should be set to a small partion size
     leaving you with some unpartioned space.
     * You will need to leave unformatted space on the drive for docker. Try to leave at least 50 unformated for
     the docker LVM partion that is described in the "Create Partion for Docker LVM" section below.
 * Turn on your wired internet connection.  It should just be a toggle switch for your device.
 * Once the install starts it asks for a root password and a first user.
   * Having a `centos` admin user will match what happens in cloud environments.


Once rebooted,
if you forgot to turn on your internet in the install, you can set it up like so
http://www.krizna.com/centos/setup-network-centos-7/ .  It might be easier and more
automated (therefore less error prone) to just reinstall and remember to turn on your internet during the install.


### Set up Base Network

#### Chosing a static IP range

I chose 172.16.222.x because its unlikely to overlap with any network I might move this cluster too.

#### Give it a static IP and set DNS and Gateway

http://ask.xmodulo.com/configure-static-ip-address-centos7.html

At the command line enter:

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


Edit `/etc/sysconfig/network-scripts/ifcfg-eno1`

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

The dns lines are going to have to change once consul is up.

NOTE: in centos 7 /etc/resolv.conf is a generated file.

You could also put the dns lines in /etc/sysconfig/network.

Permanently change your hostname with:

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
   * you kinda want all your machines to use the same partition because this partition is entered as a system wide variable.
 * first sector: default
 * last sector: +50G
 * Command: w

 * reboot


Don't put a file system on the partion.

Note that I am creating a partion size 50 Gigs, this is for docker.  Just make it consistent across your cluster.

There are two main types of drives on the market today. The older type of drive is said to have MS-DOS partions. When
partioning these types of drives you will be asked if you want to create a `primary` partion or a `extended` partition.
You will need to make it a `primary` partition.

Additionally, if you have a MS-DOS partioned drive you may have to run the following patch https://github.com/ansible/ansible-modules-extras/issues/1504
against the file /Library/lvg.py. If during the ansible run (as described in the section "Run It!" below) the run hangs
on task "lvm | create volume group" then you will need to follow the instructions in issue 1504.

## Creating Your Inventory

Here is an example inventory file. It should be placed in the root of the mantl directory.

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

I had to add the ansible_ssh_host line to run `playbooks/reboot-hosts.yml` and the private_ipv4 is needed by several roles.

The dc=dc1 group is needed to set `consul_dc_group` in the consul roles. It is specifically used in the
dnsmasq role.

Note that dc1 is the default.  If you change the name of the data center in your inventory file
you will need to set the consul_dc variable.  For example, if you called your dc 'mydc' then you
would need to enter:

    ansible-playbook -u centos -i inventory -e consul_dc=mydc \
            -e provider=bare-metal  -e @security.yml  sample.yml >& bare-metal.log

The rest of the options will be discussed below.

## Getting Started with Ansible


Add your key to all the machines in your inventory

    ansible all -i inventory  -u centos -k -m authorized_key -a "user=centos key=https://github.com/youraccount.keys"

Note this makes use of your public key on Github.  If you don't have a Github account or a key pair on your Github
account, please look at the documentation for Ansible authorized_key module for other options.

The -k is needed because the ssh connection is still uses password based authentication.

After this authorization step has been completed, all commands can happen without the password and -k option.
Test with:

    ansible all -i inventory -u centos -m ping

You should get back a pong from each machine in your inventory.

### Copy the /etc/host file over

Add the nodes to /etc/hosts

content is:

        127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4
        ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
        172.16.222.5 MyMac
        172.16.222.6 control-01
        172.16.222.7 control-02
        172.16.222.8 control-03
        172.16.222.11 worker-01
        172.16.222.12 worker-02
        172.16.222.13 worker-03
        172.16.222.16 edge-01
        172.16.222.17 edge-02

Copy the /etc/hosts file over.

    ansible all -i inventory -u centos --sudo --ask-sudo-pass -m copy -a "src=hosts dest=/etc/hosts"


## Run It!

You now are ready to run the playbook.  Change directory to the mantl root.  Your inventory should be there as well as
the file `security_setup` (along with quite a few others).

Run the security-setup script:

    ./security-setup

It asks for one admin password. At the end of that run there will be a `security.yml` file.  It will have the password
you entered and a lot of keys needed for installation.

The playbook you will be running is `sample.yml`.  Since you created your own inventory and didn't use terraform,
there are a few variables you need to set for your run.

    ansible-playbook -u centos -i inventory \
            -e provider=bare-metal \
            -e consul_dc=dc1 \
            -e docker-lvm-backed=true \
            -e docker_lvm_data_volume_size="80%FREE" \
            -e @security.yml  sample.yml >& bare-metal.log


In another window tail -f  that log file to follow whats going on.

The meaning of the parts of this command are as follows:

 * ansible-playbook -u centos -i inventory
   * run the ansible play book as centos user against the inventory found in the ./inventory file.
 * -e provider=bare-metal
   * The "provider" is bare-metal where a user sets up the infrastructure and then creates an inventory file as described
   above. If the inventory had been generated by terraform.py against a terraform state file for infrastructure
   built on Google Cloud, this value would have been set automatically to 'gcs'
 * -e consul_dc=dc1
   * This is the name found in your ./inventory file for your datacenter.
 * -e docker-lvm-backed=true
   * lvm backed docker is a really good idea in centos. This is why you craeted the extra partion during installation.
 * -e docker_lvm_data_volume_size="80%FREE"
   * This defaults to "40%FREE" in the docker role because the default LVM partition is shared with other things.
   You could leave this off, but its likely with your own hardware you will have different constraints and its a good
   variable to know.
 * -e @security.yml
   * this a series of environment variable settings that have all the security settings of the varios parts of mantl. The @
   causes ansible to evaluate the file.
 * sample.yml
   * this is the ansible file that is being run.
 * >& bare-metal.log
   * this redirects the output to a file so that you can review it later.   Tailing with a -f flag lets you watch the
   progress as ansible works through the rolls accross your inventory.


Once you are done go to the browser and go to the /ui directory of any control node and you should see the Mantl UI.  For the
inventory shown above, you could go to `172.16.222.6/ui` and you should see the Mantl UI.

