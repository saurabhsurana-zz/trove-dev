# -*- mode: ruby -*-
# vi: set ft=ruby :

RAM = 12240
CPU = 4

OPENSTACK_SOURCE_DIR = ENV['OPENSTACK_SOURCE_DIR']
#OPENSTACK_SOURCE_DIR = ENV['OPENSTACK_SOURCE_DIR'] || raise('Please set env variable "OPENSTACK_SOURCE_DIR')
OPENSTACK_SYNC_DIR = ENV['OPENSTACK_SYNC_DIR'] || "/home/vagrant/shared-stack"
ENABLE_NEUTRON = ENV['ENABLE_NEUTRON'] || "true"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "juice/box-apple-trusty-xl"

  if OPENSTACK_SOURCE_DIR
      config.vm.synced_folder OPENSTACK_SOURCE_DIR, OPENSTACK_SYNC_DIR, 
          create: true, 
          type: "rsync",
          owner: "vagrant", 
          group: "vagrant", 
          rsync__auto: true,
          rsync__args: ["--verbose", "--archive", "-z", "--copy-links"],
          rsync__exclude: ["*/.tox/", "*/.venv/"]
  end

  # ########################################
  # other sync directories/provisioning scripts

  # ########################################

  if OPENSTACK_SOURCE_DIR
      config.vm.provision "check_source", type: "shell", run: "always" do |s|
          s.path = "common/check_source.bash"
          s.args = [OPENSTACK_SYNC_DIR]
      end
  end
 
  config.vm.provision "bootstrap_redstack", type: "shell", run: "always" do |s|
      s.path = "bootstrap/bootstrap_redstack.bash"
      s.args = [ENABLE_NEUTRON]
  end

  # ########################################
  # add other ports

  # ########################################

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["memsize"] = RAM
    v.vmx["numvcpus"] = CPU
    v.vmx["vhv.enable"] = TRUE
    v.gui = true
  end

end
