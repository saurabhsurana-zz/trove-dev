#!/bin/bash -x

ENABLE_NEUTRON=${ENABLE_NEUTRON:-true}
SEC_GROUP=${SEC_GROUP:-devstack}
IMAGE_NAME=${IMAGE_NAME:-Ubuntu Server 14.0}
KEY_NAME=${KEY_NAME:-bigdata-team}
NETWORK_NAME=${NETWORK_NAME:-devstack}
FLAVOR=${FLAVOR:-104}
AZ=${AZ:-az3}

TAG=`date +"%m%d%H%M"`
if [ ${ENABLE_NEUTRON} == true ]
then
    AUTO_INSTANCE_NAME=bd-dev-neutron-net-${TAG}
else
    AUTO_INSTANCE_NAME=bd-dev-nova-net-${TAG}
fi

INSTANCE_NAME=${1:-$AUTO_INSTANCE_NAME}


nova secgroup-list | grep ${SEC_GROUP}
if [ $? -ne 0 ]; then
    echo "ERROR: Security group ${SEC_GROUP} not found. Set SEC_GROUP to use different security group"
    exit 1
fi

nova keypair-list | grep ${KEY_NAME}
if [ $? -ne 0 ]; then
    echo "ERROR: keypair ${KEY_NAME} not found. Set KEY_NAME to use different keypair"
    exit 1
fi

IMAGE_ID=`nova image-list | grep "${IMAGE_NAME}" | grep -v deprecated | awk '{print $2}'`
if [ $? -ne 0 ]; then
    echo "ERROR: Image ${IMAGE_NAME} not found. Set IMAGE_NAME to use different image"
    exit 1
fi

NET_ID=`neutron net-list | grep ${NETWORK_NAME} | awk '{print $2}'`
if [ $? -ne 0 ]; then
    echo "ERROR: Neutron network ${NET_ID} not found. Set NET_ID to use different neutron network"
    exit 1
fi

rm -rf cloudinit-redstack.bash

if [ -f cloudinit-redstack ]
then
    sed "s/ENABLE_NEUTRON_VALUE/$ENABLE_NEUTRON/g" cloudinit-redstack  > cloudinit-redstack.bash
fi

nova boot --image ${IMAGE_ID} --flavor ${FLAVOR} --security_group ${SEC_GROUP} --key_name ${KEY_NAME} --nic net-id=${NET_ID} --availability_zone ${AZ} --user_data cloudinit-redstack.bash ${INSTANCE_NAME}
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create nova instance"
    exit 1
else
    INSTANCE_ID=`nova show ${INSTANCE_NAME} | grep id | grep -v user_id | grep -v tenant_id | awk '{print $4}'`
    FLOATING_IP=`nova floating-ip-list | grep Ext-Net | grep None | head -n 1 | awk '{print $2}'`
    if [ $? -ne 0 ] || [ -z ${FLOATING_IP} ]; then
        FLOATING_IP=`nova floating-ip-create | grep Ext-Net | grep None | head -n 1 | awk '{print $2}'`
        if [ $? -ne 0 ]; then
            echo "ERROR: Failed to associate floating ip with the Instance ${INSTANCE_ID}"
            exit 1
        fi
    fi
    echo "Waiting for floating ip"
    sleep 20
    nova add-floating-ip ${INSTANCE_ID} ${FLOATING_IP}
fi
