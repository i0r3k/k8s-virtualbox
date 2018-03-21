# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

	config.vm.define "master", primary: true do |master|
		master.vm.box = "centos/7"
		master.vm.box_version = "1802.01"

		master.vm.box_check_update = false
	  
		master.vm.hostname = "vg-k8s-master"
	  
		master.vm.network "private_network", ip: "192.168.33.10"

		master.vm.provider "virtualbox" do |vb|
			vb.name = "vg-k8s-master"
			vb.memory = "2048"
			vb.cpus = "2"
		end
		
		master.vm.provision "shell", path: "preflight.sh"
		
		master.vm.provision "shell", inline: <<-SHELL
			# allow root to run kubectl
			echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
			source ~/.bash_profile

			# initialize k8s master node
			kubeadm init --apiserver-advertise-address 192.168.33.10 --kubernetes-version v1.9.5 --pod-network-cidr 10.244.0.0/16 > ~/install.log

			# grep the join command
			sed -n '/kubeadm join/p' ~/install.log > ~/join.txt
			cp ~/join.txt /home/vagrant/join.txt

			# install flannel
			kubectl apply -f ~/k8s-utils/yaml/kube-flannel-vagrant.yml
		SHELL
	end
	
	config.vm.define "node1" do |node1|
		node1.vm.box = "centos/7"
		node1.vm.box_version = "1802.01"

		node1.vm.box_check_update = false
	  
		node1.vm.hostname = "vg-k8s-node1"
	  
		node1.vm.network "private_network", ip: "192.168.33.11"

		node1.vm.provider "virtualbox" do |vb|
			vb.name = "vg-k8s-node1"
			vb.memory = "2048"
			vb.cpus = "2"
		end
		
		node1.vm.provision "shell", path: "preflight.sh"
		
		node1.vm.provision "shell", inline: <<-SHELL
			echo "initialize node1"
			
			echo "192.168.33.10" > ~/server.txt
			ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts
			sshpass -p "vagrant" scp vagrant@192.168.33.10:/home/vagrant/join.txt ~/join.txt
			source ~/join.txt
		SHELL
	end
	
	config.vm.define "node2" do |node2|
		node2.vm.box = "centos/7"
		node2.vm.box_version = "1802.01"

		node2.vm.box_check_update = false
	  
		node2.vm.hostname = "vg-k8s-node2"
	  
		node2.vm.network "private_network", ip: "192.168.33.12"

		node2.vm.provider "virtualbox" do |vb|
			vb.name = "vg-k8s-node2"
			vb.memory = "2048"
			vb.cpus = "2"
		end
		
		node2.vm.provision "shell", path: "preflight.sh"
		
		node2.vm.provision "shell", inline: <<-SHELL
			echo "initialize node2"
			
			echo "192.168.33.10" > ~/server.txt
			ssh-keyscan -f ~/server.txt >> ~/.ssh/known_hosts
			sshpass -p "vagrant" scp vagrant@192.168.33.10:/home/vagrant/join.txt ~/join.txt
			source ~/join.txt
		SHELL
	end
end
