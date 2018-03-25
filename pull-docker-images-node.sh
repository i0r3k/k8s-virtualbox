#!/bin/bash

k8s_version=$1
docker_registry="registry.cn-hangzhou.aliyuncs.com/ctag"

# pull all required docker images
docker pull $docker_registry/kube-proxy-amd64:$k8s_version
docker tag $docker_registry/kube-proxy-amd64:$k8s_version gcr.io/google_containers/kube-proxy-amd64:$k8s_version

docker pull $docker_registry/pause-amd64:3.0
docker tag $docker_registry/pause-amd64:3.0 gcr.io/google_containers/pause-amd64:3.0

docker pull $docker_registry/flannel:v0.9.1-amd64
docker tag $docker_registry/flannel:v0.9.1-amd64 quay.io/coreos/flannel:v0.9.1-amd64 