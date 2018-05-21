#!/bin/bash

k8s_master_ip=$1

# import ssh keys 
#echo $k8s_master_ip > ~/server.txt
#mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
#ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts

# get the join command
sshpass -p "vagrant" scp -o StrictHostKeyChecking=no root@$k8s_master_ip:/root/join.txt ~/join.txt

# join cluster
source ~/join.txt