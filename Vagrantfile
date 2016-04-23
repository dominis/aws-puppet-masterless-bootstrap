Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", 4096]
    v.customize ["modifyvm", :id, "--cpus", 4]
  end
  config.ssh.forward_agent = true
  config.ssh.insert_key = false
  config.vm.box = "ubuntu/wily64"

  config.vm.synced_folder ".", "/tmp/bootstrap"
  config.vm.provision "file", source: "~/.ssh/gitlab_deploy", destination: ".ssh/id_rsa"

  config.vm.provision :shell do |shell|
    shell.inline = "/bin/sh /tmp/bootstrap/bootstrap.sh"
  end

end
