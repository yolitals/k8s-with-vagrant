#!/bin/bash

# Set kubernetes repository
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sed -i 's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /etc/ssh/sshd_config 

#Docker prerequisites 
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

#Add repo for docker
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

#Install docker community edition
sudo yum install -y docker-ce-18.06.1.ce-3.el7

#Install Kubeadm
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

#Start services
systemctl enable kubelet && systemctl start kubelet

#Aditional config
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

#Start services
sudo systemctl start docker
sudo swapoff -a

# allow user and pass conection
sudo sed -i 's/^#PasswordAuthentication yes$/PasswordAuthentication yes/' /etc/ssh/sshd_config 
sudo sed -i 's/^PasswordAuthentication no$/#PasswordAuthentication no/' /etc/ssh/sshd_config 
sudo service sshd restart