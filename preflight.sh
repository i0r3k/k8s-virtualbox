#!/bin/bash

k8s_version=$1

#update to latest and install required packages
yum -y update
yum install -y git sed sshpass ntp
systemctl enable ntpd && systemctl start ntp
yum install -y docker-1.13.1-53.git774336d.el7.centos.x86_64
systemctl enable docker && systemctl start docker

#turn off firewall
systemctl disable firewalld && systemctl stop firewalld

# enable sshd password auth
sed -re 's/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config
systemctl restart sshd

#turn off swap
swapoff -a 
sed 's/.*swap.*/#&/' /etc/fstab

#turn off SELINUX
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sed -i '$a\net.bridge.bridge-nf-call-iptables=1' /etc/sysctl.conf
sed -i '$a\net.bridge.bridge-nf-call-ip6tables=1' /etc/sysctl.conf

# install kubeadm kubelet and kubectl
git clone https://github.com/linyang0625/k8s-utils ~/k8s-utils
yum install -y ~/k8s-utils/rpm/$k8s_version/*.rpm
systemctl enable kubelet && systemctl start kubelet

# pull all required docker images
docker pull iorek/kube-proxy-amd64:$k8s_version
docker tag iorek/kube-proxy-amd64:$k8s_version gcr.io/google_containers/kube-proxy-amd64:$k8s_version

docker pull iorek/kube-controller-manager-amd64:$k8s_version
docker tag iorek/kube-controller-manager-amd64:$k8s_version gcr.io/google_containers/kube-controller-manager-amd64:$k8s_version

docker pull iorek/kube-apiserver-amd64:$k8s_version
docker tag iorek/kube-apiserver-amd64:$k8s_version gcr.io/google_containers/kube-apiserver-amd64:$k8s_version

docker pull iorek/kube-scheduler-amd64:$k8s_version
docker tag iorek/kube-scheduler-amd64:$k8s_version gcr.io/google_containers/kube-scheduler-amd64:$k8s_version

docker pull iorek/etcd-amd64:3.1.11
docker tag iorek/etcd-amd64:3.1.11 gcr.io/google_containers/etcd-amd64:3.1.11

docker pull iorek/pause-amd64:3.0
docker tag iorek/pause-amd64:3.0 gcr.io/google_containers/pause-amd64:3.0

docker pull iorek/k8s-dns-dnsmasq-nanny-amd64:1.14.7
docker tag iorek/k8s-dns-dnsmasq-nanny-amd64:1.14.7 gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7

docker pull iorek/k8s-dns-sidecar-amd64:1.14.7
docker tag iorek/k8s-dns-sidecar-amd64:1.14.7 gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7

docker pull iorek/k8s-dns-kube-dns-amd64:1.14.7
docker tag iorek/k8s-dns-kube-dns-amd64:1.14.7 gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7

docker pull iorek/flannel:v0.9.1-amd64
docker tag iorek/flannel:v0.9.1-amd64 quay.io/coreos/flannel:v0.9.1-amd64 

docker pull iorek/kubernetes-dashboard-amd64:v1.8.3
docker tag iorek/kubernetes-dashboard-amd64:v1.8.3 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.3 

# ip-hostname mapping
echo "192.168.33.10 vg-k8s-master
192.168.31.11 vg-k8s-node-1
192.168.32.12 vg-k8s-node-2
192.168.33.13 vg-k8s-node-3" >> /etc/hosts

# create regular user
useradd -U k8s
usermod -aG wheel k8s

# change time zone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai