#!/bin/bash

k8s_version=$1
docker_registry=$2

#update to latest packages
yum -y update

#turn off firewall
systemctl disable firewalld && systemctl stop firewalld

# enable sshd password auth
sed -re 's/^(PasswordAuthentication)([[:space:]]+)no/\1\2yes/' -i.`date -I` /etc/ssh/sshd_config
systemctl restart sshd

# install required packages
yum install -y git sed sshpass ntp wget net-tools bind-utils bash-completion

# enable & start ntpd
systemctl enable ntpd && systemctl start ntpd
# change time zone
cp -fv /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

# install docker
yum install -y docker-1.13.1-53.git774336d.el7.centos.x86_64
systemctl enable docker && systemctl start docker
# Aliyun docker registry
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://yf758kjo.mirror.aliyuncs.com"]
}
EOF
sed -i 's/log-driver=journald/log-driver=json-file/g' /etc/sysconfig/docker
systemctl daemon-reload && systemctl restart docker

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
#yum install -y ~/k8s-utils/rpm/$k8s_version/*.rpm
tee -a /etc/yum.repos.d/kubernetes.repo <<-'EOF'
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=0
EOF
yum install -y \
	kubelet-1.10.0-0.x86_64 \
	kubectl-1.10.0-0.x86_64 \
	kubeadm-1.10.0-0.x86_64 \
	kubernetes-cni-0.6.0-0.x86_64 \
	socat-1.7.3.2-2.el7.x86_64
cat > /etc/systemd/system/kubelet.service.d/20-pod-infra-image.conf <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--pod-infra-container-image=$docker_registry/pause-amd64:3.1"
EOF
systemctl enable kubelet && systemctl start kubelet

# ip-hostname mapping
tee /etc/hosts <<-'EOF'
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.33.10 vg-k8s-master
192.168.33.11 vg-k8s-node-1
192.168.33.12 vg-k8s-node-2
192.168.33.13 vg-k8s-node-3
EOF

# create regular user(no need for provisoning with vagrant)
#useradd -U k8s
#usermod -aG wheel k8s