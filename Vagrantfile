# -*- mode: ruby -*-
# vi: set ft=ruby :
require "yaml"

config_hash = {
  "worker_count" => 1,
  "kubeworker_count" => 1,
  "control_count" => 1,
  "edge_count" => 1,
  "kubeworker_ip_start" => "192.168.100.15",
  "worker_ip_start" => "192.168.100.20",
  "control_ip_start" => "192.168.100.10",
  "edge_ip_start" => "192.168.100.25",
  "kubeworker_memory" => 1024,
  "worker_memory" => 1024,
  "control_memory" => 1024,
  "edge_memory" => 512,
  "worker_cpus" => 1,
  "kubeworker_cpus" => 1,
  "control_cpus" => 1,
  "edge_cpus" => 1,
  "network" => "private",
  "playbooks" => ["/vagrant/sample.yml"]
}

config_path = File.join(File.dirname(__FILE__), "vagrant-config.yml")
if !File.exist? config_path
  puts "No vagrant-config.yml found, using defaults"
else
 config_hash = config_hash.merge(YAML.load(File.read(config_path)))
end

def spin_up(config_hash:, config:, server_array:, hostvars:, hosts:, server_type:)
  (1..config_hash["#{server_type}_count"]).each do |w|
    hostname = "#{server_type}-00#{w}"
    ip = config_hash["#{server_type}_ip_start"] + "#{w}"

    config.vm.define hostname do |server|
      # Tested with 2 workers w/ 512mb, and a single one w/ 1024mb memory.
      server.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", config_hash["#{server_type}_cpus"]]
        vb.customize ["modifyvm", :id, "--memory", config_hash["#{server_type}_memory"]]
      end
      server.vm.hostname = hostname
      server.vm.network "#{config_hash['network']}_network", :ip => ip

      hosts += "#{ip}    #{hostname}\n"
      # Update Ansible variables
      server_array << hostname
      server_hostvars = {
        hostname => {
          "ansible_ssh_host" => ip,
          "private_ipv4" => ip,
          "public_ipv4" => ip,
          "role" => server_type
        }
      }
      hostvars.merge!(server_hostvars)
    end
  end
end

Vagrant.require_version ">= 1.8"

Vagrant.configure(2) do |config|
  # Prefer VirtualBox before VMware Fusion
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"
  config.vm.box = "CiscoCloud/mantl"

  # Disable shared folder(s) for non-provisioning machines
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

  # All hostvars will be stored in this hash, progressively as the VMs are made
  # and configured. These lists will hold hostnames that belong to these groups.
  hostvars, workers, controls, edges = {}, [], [], []
  # This variable will be appended to the /etc/hosts file on the provisioner
  hosts = ""

  spin_up(config_hash: config_hash, config: config, hostvars: hostvars, server_array: workers, hosts: hosts, server_type: 'worker')
  spin_up(config_hash: config_hash, config: config, hostvars: hostvars, server_array: workers, hosts: hosts, server_type: 'kubeworker')
  spin_up(config_hash: config_hash, config: config, hostvars: hostvars, server_array: edges, hosts: hosts, server_type: 'edge')

  (1..config_hash["control_count"]).each do |c|
    hostname = "control-0#{c}"
    ip = config_hash["control_ip_start"] + "#{c}"
    last = (c >= config_hash["control_count"])

    config.vm.define hostname, primary: last do |control|
      control.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", config_hash["control_cpus"]]
        vb.customize ["modifyvm", :id, "--memory", config_hash["control_memory"]]
      end
      control.vm.hostname = hostname
      control.vm.network "#{config_hash['network']}_network", :ip => ip
      hosts += "#{ip}    #{hostname}\n"
      controls << hostname
      control_hostvars = {
        hostname => {
          "ansible_ssh_host" => ip,
          "private_ipv4" => ip,
          "public_ipv4" => ip,
          "role" => "control"
        }
      }
      hostvars.merge!(control_hostvars)

      if last # Only run Ansible after all hosts are up
        # Sync Mantl source code, get required provisioning packages
        control.vm.synced_folder ".", "/vagrant", type: "rsync",
          rsync__exclude: [
            ".terraform/", ".git/", ".vagrant/", "docs/", "builds/",
            "packer_cache/"
        ]
        control.vm.provision "shell" do |s|
          s.path = "vagrant/provision.sh"
          s.args = [hosts]
        end

        workers = controls if workers.empty?
        ansible_groups = {
          "role=control" => controls,
          "role=control:vars" => { "consul_is_server" => true },
          "role=worker" => workers,
          "role=worker:vars" => { "consul_is_server" => false },
          "role=edge" => edges,
          "role=edge:vars" => { "consul_is_server" => false },
          "dc=vagrantdc" => workers + controls + edges,
          "dc=vagrantdc:vars" => {
            # Ansible 2.0 depreciates the 'ssh' in these vars
            "ansible_ssh_user" => "vagrant",
            "ansible_ssh_pass" => "vagrant",
            "consul_dc" => "vagrantdc",
            "provider" => "virtualbox",
            "publicly_routable" => true
          }
        }

        # Then use the built-in ansible provisioner
        config_hash["playbooks"].each do |playbook|
          control.vm.provision "ansible_local" do |ansible|
            ansible.install = false # should be installed via provision.sh
            ansible.playbook = playbook
            ansible.limit = "all"
            ansible.raw_arguments = ["-e", "@/vagrant/security.yml"]
            ansible.groups = ansible_groups
            ansible.host_vars = hostvars
          end
        end
      end
    end
  end
end
