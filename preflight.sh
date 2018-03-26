#!/bin/bash

k8s_version=$1
docker_registry="registry.cn-hangzhou.aliyuncs.com/ctag"

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
#swapoff -v /dev/VolGroup00/LogVol01
#lvm lvremove -y /dev/VolGroup00/LogVol01
sed -i 's/.*swap.*/#&/' /etc/fstab
cat /proc/swaps # free


#turn off SELINUX
setenforce 0
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config

sysctl -w net.bridge.bridge-nf-call-iptables=1
sysctl -w net.bridge.bridge-nf-call-ip6tables=1
sed -i '$a\net.bridge.bridge-nf-call-iptables=1' /etc/sysctl.conf
sed -i '$a\net.bridge.bridge-nf-call-ip6tables=1' /etc/sysctl.conf

# install kubeadm kubelet and kubectl
git clone https://code.aliyun.com/ericlin0625/k8s-utils.git ~/k8s-utils
yum install -y ~/k8s-utils/rpm/$k8s_version/*.rpm
systemctl enable kubelet && systemctl start kubelet

# Aliyun docker registry
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://yf758kjo.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

# ip-hostname mapping
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.33.10 vg-k8s-master
192.168.33.11 vg-k8s-node-1
192.168.33.12 vg-k8s-node-2
192.168.33.13 vg-k8s-node-3" > /etc/hosts

# create regular user
useradd -U k8s
usermod -aG wheel k8s

# change time zone
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai