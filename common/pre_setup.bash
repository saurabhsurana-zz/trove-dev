#!/bin/bash -x

function cleanup(){
    sudo rm -rf /opt/stack/data/*
    sudo rm -rf /opt/stack/logs/*
    sudo rm -rf /var/tmp/*
    sudo rm -rf /tmp/*
    sudo rm -rf /var/log/mysql/*
}

function install_apt_repos() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install git git-core wget libxml2-dev libxslt1-dev python-pexpect apache2 bc debhelper curl sshpass -y
}


function checkout_sources() {
    cd ${VM_USER_HOME}
    if ! [ -d trove-integration ]
    then
        git clone git://git.openstack.org/openstack/trove-integration
    else
        echo "WARN: trove-ingration directory already exist"
    fi

    if ! [ -d devstack ]
    then
        git clone git://git.openstack.org/openstack-dev/devstack
    else
        echo "WARN: devstack directory already exist"
    fi
    chown -R ${VM_USER}:${VM_USER} ${VM_USER_HOME}
}




function apply_git_reviews() {
    if [ $APPLY_GIT_REVIES == true ]
    then
        pushd  /opt/stack/trove
        git config user.email "test@example.com"
        git config user.name "test"
        popd

        pushd  /opt/stack/python-troveclient
        git config user.email "test@example.com"
        git config user.name "test"
        popd

        if [ -f /vagrant/reviews.rc ]
        then
            cp /vagrant/reviews.rc ${VM_USER_HOME}/trove-integration/scripts/
        fi
    fi
}

function install_ssh_keys() {
    # this will allows reuse of existing built images
    cd ${VM_USER_HOME}
    mkdir -p ${VM_USER_HOME}/.ssh

    cat > ${VM_USER_HOME}/.ssh/id_rsa.pub << EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD1nCGK6wvNvCfUD3UO0dLSpaTuHa5LTQXgZ7Q5pYL4u8nalQo1DQL7jEhrBLi32zeSPGsp6a8EFxipoXiUv7phWktWPYkRZiwLt3wymTjTIUF8LMsUZIPA0+OkvhsPYEVnS4/hedEADiV8hTbmf+aJE67dzmtZjkO/i3/bMrfPLcNrgA149phK4hYqOza+FduSs+BTXg97XveguVG+VxwNi7p9c+mFsPJhzOpCmTXTAbyTzDy00ZnoYMc/CJdaeK2erUdoAKX7FIiTAxHSyuVBQo7xuiAhGPwR7IMTaZe6S68AQpRRMzurDSfRVqg7vE9xbIT46570MBcFNU7vN7L redstack
EOF

    cat > ${VM_USER_HOME}/.ssh/id_rsa << EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAw9ZwhiusLzbwn1A91DtHS0qWk7h2uS00F4Ge0OaWC+LvJ2pU
KNQ0C+4xIawS4t9s3kjxrKemvBBcYqaF4lL+6YVpLVj2JEWYsC7d8Mpk40yFBfCz
LFGSDwNPjpL4bD2BFZ0uP4XnRAA4lfIU25n/miROu3c5rWY5Dv4t/2zK3zy3Da4A
NePaYSuIWKjs2vhXbkrPgU14Pe173oLlRvlccDYu6fXPphbDyYczqQpk10wG8k8w
8tNGZ6GDHPwiXWnitnq1HaACl+xSIkwMR0srlQUKO8bogIRj8EeyDE2mXukuvAEK
UUTM7qw0n0VaoO7xPcWyE+Oue9DAXBTVO7zeywIDAQABAoIBAQC63rywyquawgoJ
e0AEbCwzpBDbFIH1YTT72Sv6mo1C+mDKc6Oq8hJX8Anh35iF9DymP2SdI7zuZ45A
dDX9KMUlf7BFHUaChgaU16PgSMDMRBALAwt1lsCQotAfdA6o+mdagInJA7USJkPY
kQ9mHSTRqSOXrsTSuWBo9hJeUSmkqVeSOgKbsDhZpcdw5GlRniPGgVDNoEEZhNjf
iPTWFGF/rtzy8ZxoJW7l9s0bg4srf+aYvlZnYZHGTm+8xjG5rB3gWKn1VtJNAkCd
Ndd1zZ7vy24frQuP8pkNmuQPQKc5tPRj7rpvwg2dUMljZkvgTGKBa7SsgRYFiTdk
fqzL0U9BAoGBAOBri8L8pyJGYGN6Ja0i7xZLwxDA+ohl/sa8NsA0/0YfkmkQE/aL
lzQrjnkr9xjb6Cqjw4zTNqaXUKm7hHBvXA3hkoh4uC71n4MQqSTC+fh7vwoyorvI
rKi05undbE+0rQHZdynRUEz5krw+j7zmjf45fncIE/hsowyaAQ2v5pIHAoGBAN9l
PyMIoDotNMnMnascg0FxgBWr+4B9Ocqh2Qvj3HNv2SKOd4OnYKZUwQJ2MgVYlOCg
h3PksjvliVEQ0J12VP9Bm3drKmg73/Xg+jopJ9FrK1nSNUGoOpjP0FGW+G7S/Zl6
OEXU9BW4yDmUnjx4ByPBpB1wp7bRcxPSGXj4igwdAoGAAgRVbDozElbJlPtLDWRL
+8pQhX0Gg2VPRd/5Kf8P8ERmX3VaiJO2lyxxClu/y8RmMMPqBQD888BWZEAgL5aA
oEtPstRK63kfpuDmdEMgVgBetivAVKm4C4gcrytjRtAb4fFfZcvQyfBQRkrVpd/4
lLlVjqJO86OeT4Wuzr2u988CgYEAyKf2iA9NbDQCwGgMDxAzTWsXc1/hLc5NRJcP
j8CB2SZT0NhKvXRwObbTDtT/pRGl2AYY5J49AdPw/WGvIGCThBt3+1HE648sYXxN
BkTFQTOT4sAPmgPzbiLrqP2D9HeL1nmTZhYbkA9DuYSmhQYC07kxIkh4PJvxU5JZ
0vDbfnkCgYA9IDJJzuFur5lbIgPcklYBzNCfE3ufkz5FS0THcyi60gMPDVIRtx6V
/8FAGBZI4rHEMsqISVtBxoc045Ao2XOKoZF2Bz6hkxFI9eWGH9/IOiVhsSgGwRme
HoDXQMXLAyVCrDhxoPcOX02Aim6ueP0Z4p2ZPzW0l1zHiXN4RhhfRw==
-----END RSA PRIVATE KEY-----
EOF

}
