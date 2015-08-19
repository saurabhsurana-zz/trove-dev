#!/usr/bin/env bash

set -x

OPENSTACK_SYNC_DIR=$1
VM_USER=vagrant
VM_USER_HOME=/home/vagrant

if [ -z ${OPENSTACK_SYNC_DIR} ]
    echo "WARN: OPENSTACK_SYNC_DIR not set"
    exit 0
fi

for sync_target in `ls $OPENSTACK_SYNC_DIR`
do
    if [ "$sync_target" = 'devstack' ];
    then
        pushd ${VM_USER_HOME}
        ln -s ${OPENSTACK_SYNC_DIR}/devstack devstack
        popd
    elif [ "$sync_target" = 'trove-integration' ];
    then
        pushd ${VM_USER_HOME}
        ln -s ${OPENSTACK_SYNC_DIR}/trove-integration trove-integration
        popd
    fi
done

if ! [ -d /opt/stack ]
then
    cd /opt
    ln -s ${OPENSTACK_SYNC_DIR} stack
    chown -R ${VM_USER}:${VM_USER} stack
fi
