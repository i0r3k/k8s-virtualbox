#!/bin/bash

# allow root to run kubectl
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
source /etc/profile

ip addr show

# initialize k8s master node
kubeadm init --apiserver-advertise-address $1 --kubernetes-version $2 --pod-network-cidr 10.244.0.0/16 > ~/install.log

# grep the join command
sed -n '/kubeadm join/p' ~/install.log > ~/join.txt
cp ~/join.txt /home/vagrant/join.txt

# install flannel
kubectl apply -f ~/k8s-utils/yaml/flannel/kube-flannel-vagrant.yml

# install dashboard
kubectl create -f ~/k8s-utils/yaml/dashboard/kubernetes-dashboard.yaml
kubectl create -f ~/k8s-utils/yaml/dashboard/admin-role.yaml
kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2 > ~/admin-token.txt
echo "https://192.168.33.11:30001/" > ~/dashboard-url.txt
echo "You can access Kubernetes Dashboard with ~/admin-token.txt"
echo "URL: https://192.168.33.11:30001/"

# install Heapster
kubectl apply -f ~/k8s-utils/yaml/heapster/

# install traefik ingress controller
kubectl apply -f ~/k8s-utils/yaml/traefik-ingress/

# install EFK
# NOTE: Powerful CPU and memory allocation required. At least 4G per virtual machine.
#kubectl apply -f ~/k8s-utils/yaml/efk/