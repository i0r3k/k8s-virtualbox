#!/bin/bash

#k8s_version=$1
#docker_registry="registry.cn-hangzhou.aliyuncs.com/ctag"
docker_registry=$1

# pull all required docker images
#docker pull $docker_registry/kube-proxy-amd64:$k8s_version
#docker tag $docker_registry/kube-proxy-amd64:$k8s_version gcr.io/google_containers/kube-proxy-amd64:$k8s_version
#
#docker pull $docker_registry/kube-controller-manager-amd64:$k8s_version
#docker tag $docker_registry/kube-controller-manager-amd64:$k8s_version gcr.io/google_containers/kube-controller-manager-amd64:$k8s_version
#
#docker pull $docker_registry/kube-apiserver-amd64:$k8s_version
#docker tag $docker_registry/kube-apiserver-amd64:$k8s_version gcr.io/google_containers/kube-apiserver-amd64:$k8s_version
#
#docker pull $docker_registry/kube-scheduler-amd64:$k8s_version
#docker tag $docker_registry/kube-scheduler-amd64:$k8s_version gcr.io/google_containers/kube-scheduler-amd64:$k8s_version
#
#docker pull $docker_registry/etcd-amd64:3.1.11
#docker tag $docker_registry/etcd-amd64:3.1.11 gcr.io/google_containers/etcd-amd64:3.1.11
#
#docker pull $docker_registry/pause-amd64:3.0
#docker tag $docker_registry/pause-amd64:3.0 gcr.io/google_containers/pause-amd64:3.0
#
#docker pull $docker_registry/k8s-dns-dnsmasq-nanny-amd64:1.14.7
#docker tag $docker_registry/k8s-dns-dnsmasq-nanny-amd64:1.14.7 gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.7
#
#docker pull $docker_registry/k8s-dns-sidecar-amd64:1.14.7
#docker tag $docker_registry/k8s-dns-sidecar-amd64:1.14.7 gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.7
#
#docker pull $docker_registry/k8s-dns-kube-dns-amd64:1.14.7
#docker tag $docker_registry/k8s-dns-kube-dns-amd64:1.14.7 gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.7
#
#docker pull $docker_registry/flannel:v0.9.1-amd64
#docker tag $docker_registry/flannel:v0.9.1-amd64 quay.io/coreos/flannel:v0.9.1-amd64 
#
#docker pull $docker_registry/kubernetes-dashboard-amd64:v1.8.3
#docker tag $docker_registry/kubernetes-dashboard-amd64:v1.8.3 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.3 

docker pull $docker_registry/tiller:v2.8.2
docker tag $docker_registry/tiller:v2.8.2 gcr.io/kubernetes-helm/tiller:v2.8.2