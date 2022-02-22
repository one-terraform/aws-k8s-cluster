#! /bin/bash

#Turn off swap (Needed for kubectl to work properly)

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

#install packages
sudo apt -y update

sudo apt -y install apt-transport-https curl vim git wget

sudo su -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"

sudo su -c "echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" > /etc/apt/sources.list.d/kubernetes.list"

sudo apt -y update

sudo apt -y install kubelet kubeadm containerd kubectl

#apt-mark hold prevents deletion or upgrade of packages
sudo apt-mark hold kubelet kubeadm kubectl containerd

#Load and Configure containerd
sudo modprobe overlay
sudo modprobe br_netfilter

sudo su -c"echo \"overlay\" >> /etc/modules-load.d/containerd.conf"
sudo su -c "echo \"br_netfilter\" >> /etc/modules-load.d/containerd.conf"

#Configure required sysctl to persist across system reboots
sudo su -c"echo \"net.bridge.bridge-nf-call-iptables = 1\" >> /etc/sysctl.d/99-kubernetes-cri.conf"
sudo su -c"echo \"net.bridge.bridge-nf-call-ip6tables = 1\" >> /etc/sysctl.d/99-kubernetes-cri.conf"
sudo su -c"echo \"net.ipv4.ip_forward = 1\" >> /etc/sysctl.d/99-kubernetes-cri.conf"

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

#Initialize Manager (control plane)
sudo kubeadm init 

if [ $? -ne 0 ]
then
#IF there is an error then run:
    sudo kubeadm init --cri-socket /run/containerd/containerd.sock
fi


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

#sudo chown $USER:$USER $HOME/.kube/config
sudo chown -R $(id -u):$(id -g) $HOME/.kube/config

#Verify kubectl running
kubectl get pods -o wide -n kube-system 2> /dev/null

if [ $? -ne 0 ]
then 

#core-dns may not be running
#If not running Install weave pod network

    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

fi

#References
#-Installing and Configuring containerd as
# Kubernetes container Runtime
#https://www.nocentino.com/posts/2021-12-27-installing-and-configuring-containerd-as-a-kubernetes-container-runtime/

#-Installing kubeadm
#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

