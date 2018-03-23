#!/bin/bash

k8s_master_ip=$1

echo $k8s_master_ip > ~/server.txt
mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts
sshpass -p "vagrant" scp vagrant@$k8s_master_ip:/home/vagrant/join.txt ~/join.txt
source ~/join.txt