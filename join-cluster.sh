#!/bin/bash

k8s_master_ip=$1
node_name=$2

#sed -i 's/MountFlags=slave/MountFlags=/g' /usr/lib/systemd/system/docker.service
#systemctl daemon-reload && systemctl restart docker
#mount --make-shared /var/lib/docker/containers
#findmnt -o TARGET,PROPAGATION /var/lib/docker/containers

# import ssh keys 
#echo $k8s_master_ip > ~/server.txt
#mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
#ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts

# get the join command
sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no root@$k8s_master_ip;
#sshpass -p "vagrant" scp -o StrictHostKeyChecking=no root@$k8s_master_ip:/root/join.txt ~/join.txt
scp -o StrictHostKeyChecking=no root@$k8s_master_ip:/root/join.txt ~/join.txt
# join cluster
source ~/join.txt

# add required label for fluentd
#ssh -o StrictHostKeyChecking=no root@$k8s_master_ip "export KUBECONFIG=/etc/kubernetes/admin.conf; /vagrant/label-node.sh $node_name;"