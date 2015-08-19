#!/bin/bash -x

function setup_redstack() {
    cd ${VM_USER_HOME}
    #prepare devstack
    cd devstack

    cd ${VM_USER_HOME}
    cd trove-integration/scripts

    HOST_IP=$(ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')


    cat > ${VM_USER_HOME}/.devstack.local.conf <<EOF
IP_VERSION=4
HOST_IP=$HOST_IP
SWIFT_LOOPBACK_DISK_SIZE=10G
VOLUME_BACKING_FILE_SIZE=50G
SCREEN_LOGDIR=/opt/stack/logs/screen
ENABLED_SERVICES=key,n-api,n-cpu,n-cond,n-sch,n-crt,n-cauth,n-novnc,g-api,g-reg,c-sch,c-api,c-vol,horizon,rabbit,tempest,mysql,dstat,trove,tr-api,tr-tmgr,tr-cond,s-proxy,s-object,s-container,s-account,heat,h-api,h-api-cfn,h-api-cw,h-eng,neutron,q-svc,q-agt,q-dhcp,q-l3,q-meta
EOF

    chown -R ${VM_USER}:${VM_USER} ${VM_USER_HOME}
    chown -R ${VM_USER}:${VM_USER} ${VM_USER_HOME}

    touch /var/log/setup-devstack.log
    chown -R ${VM_USER}:${VM_USER} /var/log/setup-devstack.log

    su -c  "export ENABLE_NEUTRON=${ENABLE_NEUTRON};
            export LIBS_FROM_GIT_ALL_CLIENTS=false;
            export LIBS_FROM_GIT_ALL_OSLO=false;
            export ENABLE_CEILOMETER=false;
            export ENABLE_PROFILER=false;
            ./redstack install 2>&1 | tee /var/log/setup-devstack.log" ${VM_USER}
}