#!/bin/bash

# Enable MutatingAdmissionWebhook,ValidatingAdmissionWebhook
sed -i 's/- --admission-control=.*/- --admission-control=Initializers,NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota/' /etc/kubernetes/manifests/kube-apiserver.yaml
systemctl restart kubelet

sleep 10

# install Service Mesh
## install istio
kubectl apply -f install/kubernetes/istio.yaml
## install istio sidecar auto injector
./install/kubernetes/webhook-create-signed-cert.sh \
    --service istio-sidecar-injector \
    --namespace istio-system \
    --secret sidecar-injector-certs

kubectl apply -f install/kubernetes/istio-sidecar-injector-configmap-release.yaml

cat install/kubernetes/istio-sidecar-injector.yaml | \
     ./install/kubernetes/webhook-patch-ca-bundle.sh > \
     install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml

kubectl apply -f install/kubernetes/istio-sidecar-injector-with-ca-bundle.yaml
