#!/bin/bash -x

# Log to syslog and a separate file
exec > >(tee /var/log/setup_redstack.log | logger -t setup_redstack -s 2>/dev/console) 2>&1

ENABLE_NEUTRON=${ENABLE_NEUTRON:-$1}

if [ -z ${ENABLE_NEUTRON} ]
then
    echo "ERROR: Please set value for ENABLE_NEUTRON"
    exit 1
fi

# check if running on a vagrant vm or on ubuntu vm (cloud/vmfusion/baremetal)
id -u vagrant
if [ $? -eq 0 ]
then
    VM_USER=vagrant
    VM_USER_HOME=/home/vagrant
else
    VM_USER=ubuntu
    VM_USER_HOME=/home/ubuntu
fi

SETUP_DIR=/vagrant

if [ -d /vagrant/common ]
then
    SETUP_DIR=/vagrant
else
    cd ${VM_USER_HOME}
    if ! [ -d ${VM_USER_HOME}/trove-dev ]
    then
        git clone https://github.com/saurabhsurana/trove-dev
        SETUP_DIR=${VM_USER_HOME}/trove-dev
    fi
fi

. ${SETUP_DIR}/common/pre_setup.bash
. ${SETUP_DIR}/common/setup.bash
. ${SETUP_DIR}/common/post_setup.bash

install_apt_repos
install_ssh_keys
checkout_sources
setup_redstack

sleep 30


echo "Waiting for devstack setup"
source ${VM_USER_HOME}/devstack/openrc admin admin

# will wait for 30 mins (120 * 15 = 1800 sec)
a=0
while [ $a -lt 120 ]
do
    source ${VM_USER_HOME}/devstack/openrc admin admin
    nova list
    if [ $? -ne 0 ]
    then
        sleep 15
        echo -n "."
        a=`expr $a + 1`
    fi
done

if [ $a -eq 120 ]
then
    echo "ERROR: Failed to setup devstack"
    exit 1
fi

add_mycnf
fix_iptables
create_SVC_network
create_default_keypair
create_stack_flavors
