# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

def load_security
  fname = File.join(File.dirname(__FILE__), "security.yml")
  if !File.exist? fname
    $stderr.puts "security.yml not found - please run `./security-setup` and try again."
    exit 1
  end

  YAML.load_file(fname)
end

Vagrant.configure(2) do |config|

  # Prefer VirtualBox before VMware Fusion
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"

  config.vm.box = "CiscoCloud/microservices-infrastructure"

  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.network :forwarded_port, guest: 2181,  host: 2181  # ZooKeeper
  config.vm.network :forwarded_port, guest: 5050,  host: 5050  # Mesos leader
  config.vm.network :forwarded_port, guest: 15050, host: 15050 # Mesos leader UI
  config.vm.network :forwarded_port, guest: 5051,  host: 5051  # Mesos follower
  config.vm.network :forwarded_port, guest: 8080,  host: 8080  # Marathon
  config.vm.network :forwarded_port, guest: 18080, host: 18080 # Marathon UI
  config.vm.network :forwarded_port, guest: 8500,  host: 8500  # Consul
  config.vm.network :forwarded_port, guest: 8600,  host: 8600  # Consul DNS

  # Mesos task ports
  for i in 4000..5000
    config.vm.network :forwarded_port, guest: i, host: i
  end

  for i in 31000..32000
    config.vm.network :forwarded_port, guest: i, host: i
  end

  config.vm.provision "shell" do |s|
    s.path = "vagrant/provision.sh"
  end

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--cpus', 1]
    vb.customize ['modifyvm', :id, '--memory', 1024]
  end
end
