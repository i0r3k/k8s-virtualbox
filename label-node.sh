#!/bin/bash

node_name=$1

while [ "$(kubectl get nodes | grep $node_name | grep NotReady | wc -l)" -ne "0" ];
do 
  echo "Node is not ready, will wait for 5 seconds...";
  sleep 5;
done
sleep 10;
kubectl label nodes $node_name "beta.kubernetes.io/fluentd-ds-ready=true"