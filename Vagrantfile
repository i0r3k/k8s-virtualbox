$num_nodes = 2
$vm_cpus = 2
$vm_memory = 4096
$vm_box = "centos/7"
$vm_box_version = "1802.01"
#$vm_box = "Iorek/k8svirtualbox"
#$vm_box_version = "1.9.5"
$k8s_version = "1.10.2"
$k8s_cluster_ip_tpl = "192.168.33.%s"
$k8s_master_ip = $k8s_cluster_ip_tpl % "10"
$vm_name_tpl = "vg-k8s-%s"
#$docker_registry="registry.cn-hangzhou.aliyuncs.com/ctag"
$docker_registry="iorek"

Vagrant.configure("2") do |config|
	config.vm.define "master", primary: true do |master|
		master.vm.box = $vm_box
		master.vm.box_version = $vm_box_version

		master.vm.box_check_update = false
	  
		master.vm.hostname = $vm_name_tpl % "master"
	  
		master.vm.network "private_network", ip: $k8s_master_ip

		master.vm.provider "virtualbox" do |vb|
			vb.name = $vm_name_tpl % "master"
			vb.memory = 4096 #$vm_memory
			vb.cpus = 2 #$vm_cpus
			vb.gui = false
		end
		
		master.vm.provision :shell, :path => 'preflight.sh', :name => 'preflight.sh', :args => [$k8s_version, $docker_registry]
		
		#master.vm.provision :shell, :path => 'pull-docker-images.sh', :name => 'pull-docker-images.sh', :args => [$docker_registry]
		
		master.vm.provision :shell, :path => 'init-master.sh', :name => 'init-master.sh', :args => [$k8s_master_ip, $k8s_version, $docker_registry]
	end
	
	(1..$num_nodes).each do |i|
		config.vm.define "node#{i}" do |node|
			node.vm.box = $vm_box
			node.vm.box_version = $vm_box_version

			node.vm.box_check_update = false
		  
			node.vm.hostname = $vm_name_tpl % "node-#{i}"
		  
			node.vm.network "private_network", ip: $k8s_cluster_ip_tpl % "#{i+10}"

			node.vm.provider "virtualbox" do |vb|
				vb.name = $vm_name_tpl % "node-#{i}"
				vb.memory = $vm_memory
				vb.cpus = $vm_cpus
				vb.gui = false
			end
			
			node.vm.provision :shell, :path => 'preflight.sh', :name => 'preflight.sh', :args => [$k8s_version, $docker_registry]
			
			#node.vm.provision :shell, :path => 'pull-docker-images.sh', :name => 'pull-docker-images.sh', :args => [$docker_registry]
			
			node.vm.provision "shell", inline: <<-SHELL
				echo "initialize node-#{i}"
			SHELL
			
			node.vm.provision :shell, :path => "join-cluster.sh", :name => 'join-cluster.sh', :args => [$k8s_master_ip, $vm_name_tpl % "node-#{i}"]
		end
	end
end
