#!/bin/bash

function add_mycnf() {
    echo Adding .my.cnf file for easy DB access
    MYCNF='${VM_USER_HOME}/.my.cnf'
    if [ ! -e $MYCNF ]; then
        # Set SERVICE_HOST to not require extra functions
        SERVICE_HOST=localhost
        source ${VM_USER_HOME}/trove-integration/scripts/redstack.rc
        cat <<EOF >$MYCNF
[client]
user=root
password=$MYSQL_PASSWORD
EOF
        chown ${VM_USER_HOME}:${VM_USER_HOME} $MYCNF
    fi
}

function create_network() {
    NETWORK_NAME=${1:-SVC}

    echo Creating SVC network
    source /home/ubuntu/devstack/openrc admin admin
    neutron net-list | grep ${NETWORK_NAME} > /dev/null
    if [ $? -ne 0 ]
    then
        SVC_NETWORK=$(neutron net-create ${NETWORK_NAME} | grep " id " | get_field 2)
        SUBNET=$(neutron subnet-create ${SVC_NETWORK} 10.1.0.0/24 --name ${NETWORK_NAME}-subnet | grep " id " | get_field 2)
        ROUTER=$(neutron router-create default-router | grep " id " | get_field 2)
        PUBLIC_NETWORK=$(neutron net-show public| grep " id " | get_field 2)
        neutron router-gateway-set ${ROUTER} ${PUBLIC_NETWORK}
        neutron router-interface-add ${ROUTER} ${SUBNET}

        echo "Adding route to access SVC network"
        ROUTER_IP=$(neutron router-show ${ROUTER}|grep external_gateway_info|cut -d '|' -f 3|python -m json.tool|grep ip_address|cut -d ':' -f 2|sed "s/\"//g;s/.$//")
        sudo route add -net 10.1.0.0/24 gw $ROUTER_IP dev br-ex
    else
        echo "${NETWORK_NAME} network already exist so skipping create SVC network step"
    fi
}


function fix_iptables() {
    sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
    sudo iptables -t nat -A POSTROUTING -s 172.0.0.0/8 -o eth0 -j MASQUERADE
}

function create_default_keypair() {
    echo Creating default keypair
    nova keypair-add --pub-key /home/$USER/.ssh/id_rsa.pub default
}

function create_stack_flavors() {
    nova flavor-create tiny-stack 70 512 20 1
    nova flavor-create stack 71 1024 20 1
}
