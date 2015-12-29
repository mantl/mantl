# -*- mode: ruby -*-
# vi: set ft=ruby :
require "yaml"

# These variables can be set in "vagrant-config.yml", see vagrant/README.rst
num_workers=1
num_controls=1
worker_ip_start = "192.168.100.20"
control_ip_start = "192.168.100.10"

config_path = File.join(File.dirname(__FILE__), "vagrant-config.yml")
if !File.exist? config_path
  puts "No vagrant-config.yml found, using defaults"
else
 config_hash = YAML.load(File.read(config_path))
 num_workers = config_hash.fetch("num_workers", num_workers)
 num_controls = config_hash.fetch("num_controls", num_controls)
 worker_ip_start = config_hash.fetch("worker_ip_start", worker_ip_start)
 control_ip_start = config_hash.fetch("control_ip_start", control_ip_start)
end


# Check Vagrant version before continuing. TODO: delete when 2.0 is out.
if not `vagrant --version` =~ /(1\.([89]|1[0-9])|2\.[0-9])/
  abort("Mantl requires Vagrant 1.8 or higher, please upgrade and try again.")
end

Vagrant.configure(2) do |config|
  # Prefer VirtualBox before VMware Fusion
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_fusion"
  config.vm.box = "centos/7"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--cpus", 1]
  end

  # Disable shared folder(s) for non-provisioning machines
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

  # All hostvars will be stored in this hash, progressively as the VMs are made
  # and configured. These lists will hold hostnames that belong to these groups.
  hostvars, workers, controls = {}, [], []
  # This variable will be appended to the /etc/hosts file on the provisioner
  hosts = ""

  (1..num_workers).each do |w|
    hostname = "worker-00#{w}"
    ip = worker_ip_start + "#{w}"

    config.vm.define hostname do |worker|
      # Tested with 2 workers w/ 512mb, and a single one w/ 1024mb memory.
      worker.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 1024]
      end
      worker.vm.hostname = hostname
      worker.vm.network "private_network", :ip => ip

      hosts += "#{ip}    #{hostname}"
      # Update Ansible variables
      workers << hostname
      worker_hostvars = {
        hostname => {
          "ansible_ssh_host" => ip,
          "private_ipv4" => ip,
          "public_ipv4" => ip,
          "role" => "worker"
        }
      }
      hostvars.merge!(worker_hostvars)
    end
  end

  (1..num_controls).each do |c|
    hostname = "control-0#{c}"
    ip = control_ip_start + "#{c}"
    last = (c >= num_controls)

    config.vm.define hostname, primary: last do |control|
      control.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", 1024]
      end
      control.vm.hostname = hostname
      control.vm.network "private_network", :ip => ip
      hosts += "#{ip}    #{hostname}"
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
        control.vm.synced_folder ".", "/vagrant", type: "rsync"
        control.vm.provision "shell" do |s|
          s.path = "vagrant/provision.sh"
          s.args = [hosts]
        end
        # Then use the built-in ansible provisioner
        control.vm.provision "ansible_local" do |ansible|
          ansible.install = false # should be installed via provision.sh
          ansible.playbook = "/vagrant/terraform.sample.yml"
          ansible.limit = "all"
          ansible.raw_arguments = ["-e", "@/vagrant/security.yml"]

          ansible.groups = {
            "role=control" => controls,
            "role=control:vars" => { "consul_is_server" => true },
            "role=worker" => workers,
            "role=worker:vars" => { "consul_is_server" => false },
            "dc=vagrantdc" => workers + controls,
            "dc=vagrantdc:vars" => {
              # Ansible 2.0 depreciates the 'ssh' in these vars
              "ansible_ssh_user" => "vagrant",
              "ansible_ssh_pass" => "vagrant",
              "consul_dc" => "vagrantdc",
              "provider" => "virtualbox",
              "publicly_routable" => true
            }
          }
          ansible.host_vars = hostvars
        end
      end
    end
  end
end
