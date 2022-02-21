#! /bin/bash

#Turn off swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#install packages
sudo apt -y update
sudo apt -y install apt-transport-https curl vim git
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list

sudo apt -y update

sudo apt -y install kubelet kubeadm containerd kubectl

#apt-mark hold prevents deletion or upgrade of packages
sudo apt-mark hold kubelet kubeadm kubectl containerd

#Configure containerd
sudo echo "overlay" >> /etc/modules-load.d/containerd.conf
sudo echo "br_netfilter" >> /etc/modules-load.d/containerd.conf

sudo modprobe overlay
sudo modprobe br_netfilter

sudo echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf
sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/99-kubernetes-cri.conf


#Reload sysctl
sudo sysctl --system

#Create a containerd configuration file
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

#Set Systemd as the cgroup driver
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

#restart containerd
sudo systemctl restart containerd

#Start and Enable kubelet service
sudo systemctl daemon-reload
sudo systemctl start kubelet
sudo systemctl enable kubelet.service





#References
#-Installing and Configuring containerd as
# Kubernetes container Runtime
#https://www.nocentino.com/posts/2021-12-27-installing-and-configuring-containerd-as-a-kubernetes-container-runtime/

