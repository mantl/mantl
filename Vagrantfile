# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

def load_security
  if !File.exist? "security.yml"
    $stderr.puts "security.yml not found - please run `./security-setup` and try again."
    exit 1
  end

  YAML.load_file("security.yml")
end

Vagrant.configure(2) do |config|

  # Prefer VirtualBox before VMware Fusion
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"

  config.vm.box = "CiscoCloud/shipped-devbox"

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

  config.vm.provision "ansible" do |ansible|
    ansible.extra_vars = { ansible_ssh_user: 'vagrant' }
    ansible.playbook = "vagrant.yml"
    ansible.groups = {
      "consul_servers" => ["default"],
      "mesos_leaders" => ["default"],
      "vagrant" => ["default"],
      "zookeeper_servers" => ["default"]
    }
    ansible.extra_vars = load_security.merge({
      "consul_servers_group" => "consul_servers",
      "consul_dns_domain" => "consul",
      "consul_dc" => "vagrant",
      "consul_acl_datacenter" => "vagrant",
      "consul_bootstrap_expect" => 1,
      "mesos_cluster" => "vagrant",
      "mesos_mode" => "mixed"
    })
  end

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--cpus', 1]
    vb.customize ['modifyvm', :id, '--memory', 1024]
  end
end
