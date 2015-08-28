trove-dev
=========

Setup for creating development environments for openstack trove.

Using this setup, you have two options create dev environment
# Using Vagrant
1. You need VMWare fusion provider for vagrant
2. This needs 12G RAM and 4 CPUs (can be changed in Vagrant file)
3. Need to set appropriate environment variables

# Using Nova/Cloud VM
1. You need to have sourced your openstack account credentials
   (to check this, run command `env | grep OS`, you should see env 
   variables OS_PASSWORD, OS_AUTH_URL, OS_USERNAME, OS_TENANT_NAME)
2. With appropriate openstack credentials sourced, you can run
   script nova-boot.bash, which creates appropriate Nova VM for
   this setup. (This script has been tested against HP Public cloud)
3. Need to set appropriate environment variables


Environment Variables:
=================================
##### ENABLE_NEUTRON 
_(used by both, Vagrant and Nova/Cloud VM setup)_

This defines network configuration for your devstack environment.
Use export to set the appropriate value for this variable.
The default value for this variable is true, which setups up a
neutron based devstack environment
When this is set to false, this will setup a nova network
based neutron environment
```
# for nova network environment
export ENABLE_NEUTRON=false
```

Note: Currnetly there is a known issue with this setup, where if you
create a nova network environment, the eth0 on the VM,
looses its IP. Reason for this is, with devstack setup when nova network
is enabled, it modifies the default route on the VM to go to br100 and
thats why dhcp client fails to get the IP for eth0. Workaround
probably is to go with static IP, but its not tested yet.

##### OPENSTACK_SOURCE_DIR (Used only by Vagrant)
_(used only by Vagrant setup)_

  This should point to a local directory on your host system, that
can contain copy of openstack projects. It is recommended to maintain
a local copy of openstack projects in order to get a repetable setup
as sometimes, various openstack projects are in unstable/unusable state
which makes setting up devstack with everything upstream, highly
unreliable experience. By maintaining local copy of these projects
on your host, you will get a consistent setup everytime you do
vagrant up.
```
export OPENSTACK_SOURCE_DIR=/Users/foo/github/openstack-dev
```

Customizing Vagrant file:
It is advisable to change Vagrantfile by modifying sections between
lines marked with '#####', as it will make it easy for one to pull
in changes from upstream trove-dev repository.
There are couple of sections which are allowed to be customized, like
shared folders or provisioning scripts and alos forwarding ports etc


Building trove guest images:
The environemnt variables used on this setup/scripts are only avialable
during setup, so it is required to set these variables again while
running command/scripts on your setup as these varialble are not
made available to the VM. E.g. When building the guest images for trove
you need to set appropriat value for ENABLE_NEUTRON again.

```
export ENABLE_NEUTRON=true; ./redstack kick-start mysql
```

# Usage
========
```
git clone https://github.com/saurabhsurana/trove-dev
cd trove-dev
```

### Vagrant Setup
```
export OPENSTACK_SOURCE_DIR=/path-to-your-openstack-code
export ENABLE_NEUTRON=false
vagrant up --provider vmware_fusion
```

### Nova/Cloud VM Setup
```
source nova-stackrc     # the credentials for your could account
export ENABLE_NEUTRON=false
./nova-boot.bash
```
