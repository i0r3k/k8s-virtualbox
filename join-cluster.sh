echo "192.168.33.10" > ~/server.txt
mkdir -p ~/.ssh/ && echo "# known hosts" >> ~/.ssh/known_hosts
ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts
sshpass -p "vagrant" scp vagrant@192.168.33.10:/home/vagrant/join.txt ~/join.txt
source ~/join.txt