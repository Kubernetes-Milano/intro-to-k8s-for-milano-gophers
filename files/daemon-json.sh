#!/bin/bash

echo "DOCKER CONFIGURATION"

mkdir -p /etc/docker 

cat << EOF > /etc/docker/daemon.json
{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts" : {
       "max-size":"10m",
       "max-file": "5"
    }
}
EOF