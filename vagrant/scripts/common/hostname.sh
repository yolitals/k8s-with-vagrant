#!/bin/bash -ex
sudo echo ${HOST_NAME} > /etc/hostname
sudo echo "127.0.1.1 ${HOST_NAME}" >> /etc/hosts
