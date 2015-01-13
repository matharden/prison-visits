# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup = <<SCRIPT
ssh-keyscan github.com >> ~/.ssh/known_hosts
cd /vagrant && make clone
SCRIPT

VAGRANTFILE_API_VERSION = "2"
ENV['VAGRANT_DEFAULT_PROVIDER'] ||= "docker"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "railsapp"

  # Set up SSH agent forwarding.
  config.ssh.forward_agent = true

  # provision docker daemon
  config.vm.provision "docker"
  config.vm.provision "shell", inline: $setup, privileged: false

  config.vm.provision "docker" do |d|
    d.build_image "/vagrant", args: "-t prison-visits"
    d.run "prison-visits"
  end
end
