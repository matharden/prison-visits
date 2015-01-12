# -*- mode: ruby -*-
# vi: set ft=ruby :

# Check if the ssh-agent is running on the host
`ssh-add -l`
if not $?.success?
  puts 'Your SSH does not currently contain any keys (or is stopped.)'
  puts 'Please start it and add your SSH keys to continue.'  
  exit 1
end

$socat_install = <<INSTALL
apt-get update && apt-get install -yq socat
INSTALL

$socat_upstart = <<SOCAT
cat > /etc/init/socat-ssh.conf <<'EOF'
author "MoJ, Ltd."

env SSH_AUTH_PROXY_PORT=1234
description "socat ssh proxy"
start on (local-filesystems and net-device-up IFACE!=lo)

setuid vagrant
setgid vagrant

respawn

exec socat TCP4-LISTEN:$SSH_AUTH_PROXY_PORT,fork,bind=$(ip -o -4 addr list docker0 | awk '{print $$4}' | cut -d/ -f1) UNIX-CLIENT:$SSH_AUTH_SOCK

respawn limit 10 300

EOF
SOCAT

VAGRANTFILE_API_VERSION = "2"
ENV['VAGRANT_DEFAULT_PROVIDER'] ||= "docker"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "railsapp"

  # Set up SSH agent forwarding.
  config.ssh.forward_agent = true

  # provision docker daemon
  config.vm.provision "docker"
  # Create upstart job
  config.vm.provision "shell", inline: $socat_install
  config.vm.provision "shell", inline: $socat_upstart
  config.vm.provision "shell", inline: "service socat-ssh start"

  # provisions the Docker
  config.vm.provision "docker" do |d|
    d.build_image "/vagrant"
  end

end
