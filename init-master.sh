#!/bin/bash

k8s_master_ip=$1
k8s_version=$2
docker_registry=$3

# allow root to run kubectl
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
source /etc/profile

ip addr show

# initialize k8s master node
cat > ~/config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: $k8s_master_ip
etcd:
  image: iorek/etcd-amd64:3.1.11
networking:
  podSubnet: 10.244.0.0/16
kubernetesVersion: $k8s_version
imageRepository: $docker_registry
EOF
#kubeadm init --apiserver-advertise-address $k8s_master_ip --kubernetes-version $k8s_version --pod-network-cidr 10.244.0.0/16 > ~/install.log
kubeadm init --config ~/config.yaml > ~/install.log

# grep the join command
sed -n '/kubeadm join/p' ~/install.log > ~/join.txt
cp ~/join.txt /home/vagrant/join.txt

# pull all required YAMLs and scripts
git clone https://github.com/linyang0625/k8s-utils.git ~/k8s-utils

# install flannel
kubectl apply -f ~/k8s-utils/yaml/flannel/kube-flannel-vagrant.yml

# install dashboard
kubectl apply -f ~/k8s-utils/yaml/dashboard/kubernetes-dashboard.yaml
kubectl apply -f ~/k8s-utils/yaml/dashboard/admin-role.yaml
#kubectl apply -f ~/k8s-utils/yaml/dashboard/
kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2 > ~/admin-token.txt
echo "https://192.168.33.11:30001/" > ~/dashboard-url.txt
echo "You can access Kubernetes Dashboard with ~/admin-token.txt"
echo "URL: https://192.168.33.11:30001/"

# install Helm
# Service account with cluster-admin role
#sh ~/k8s-utils/scripts/get_helm.sh
wget https://storage.googleapis.com/kubernetes-helm/helm-v2.8.2-linux-amd64.tar.gz
tar -zxvf helm-v2.8.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
export PATH=/usr/local/bin:$PATH && echo "export PATH=/usr/local/bin:$PATH" >> ~/.bash_profile
kubectl create serviceaccount tiller --namespace kube-system
kubectl apply -f ~/k8s-utils/yaml/helm/rbac-config.yaml
helm init --service-account tiller

# install Heapster
kubectl apply -f ~/k8s-utils/yaml/heapster/

kubectl create namespace istio-system
# install traefik ingress controller
kubectl apply -f ~/k8s-utils/yaml/traefik-ingress/

# install EFK
# NOTE: Powerful CPU and memory allocation required. At least 4G per virtual machine.
#kubectl apply -f ~/k8s-utils/yaml/efk/
