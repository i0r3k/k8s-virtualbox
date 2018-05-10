#!/bin/bash
kubectl label namespace default istio-injection=enabled
kubectl create -f samples/bookinfo/kube/bookinfo.yaml
