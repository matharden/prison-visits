# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
ENV['VAGRANT_DEFAULT_PROVIDER'] ||= "docker"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "railsapp"

  # Set up SSH agent forwarding.
  config.ssh.forward_agent = true

  # provision docker daemon
  config.vm.provision "docker"
  # provsion socat-ssh
  config.vm.provision "docker" do |d|
    d.run "ministryofjustice/socat-ssh",
      args: "--name=socat-ssh --net=host -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent"
  end
  # build image and start the application
  config.vm.provision "docker" do |d|
    d.build_image "/vagrant", args: "-t prison-visits"
    d.run "prison-visits"
    d.run "jpetazzo/nsenter", args: "--rm -v /usr/local/bin:/target", daemonize: false
  end
end
