install
cdrom
text
skipx
unsupported_hardware

keyboard us
lang en_US.UTF-8
timezone --utc Etc/UTC

network --device=enp0s3 --bootproto=dhcp --ipv6=auto --activate
selinux --permissive
firewall --disabled
firstboot --disabled

rootpw --plaintext root
auth --enableshadow --passalgo=sha512 --kickstart

bootloader --timeout=1 --location=mbr
zerombr
clearpart --all
part / --fstype ext4 --size=1 --grow

repo --name="base"      --baseurl=http://mirror.centos.org/centos/7/os/x86_64
repo --name="updates"   --baseurl=http://mirror.centos.org/centos/7/updates/x86_64

%packages --nobase --ignoremissing --excludedocs
@core
-*firmware
%end

reboot

%addon com_redhat_kdump --disable
%end

%post --erroronfail
# Enable graceful showdown from 'vagrant halt'
systemctl enable acpid

# Delete anaconda-ks.cfg
rm -f /root/anaconda-ks.cfg

%end

# EOF
