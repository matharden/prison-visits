# -*- mode: ruby -*-
# vi: set ft=ruby :

DOCKER_PORT=2376
UNICORN_PORT=3000
VAGRANTFILE_API_VERSION = "2"

$docker_setup=<<CONF
cat > /etc/default/docker << 'EOF'
DOCKER_OPTS="-H 0.0.0.0:#{DOCKER_PORT} -H unix:///var/run/docker.sock"
EOF
service docker restart
CONF

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "prison-visits"
  config.vm.network "forwarded_port", guest: DOCKER_PORT, host: DOCKER_PORT
  config.vm.network "forwarded_port", guest: UNICORN_PORT, host: UNICORN_PORT

  # Set up SSH agent forwarding.
  config.ssh.forward_agent = true

  # provision docker daemon
  config.vm.provision "docker"
  config.vm.provision "shell", inline: $docker_setup

  # provsion socat-ssh
  config.vm.provision "docker" do |d|
    d.run "ministryofjustice/socat-ssh",
      args: "--name=socat-ssh --net=host -v $(readlink -f $SSH_AUTH_SOCK):/ssh-agent -e SSH_AUTH_SOCK=/ssh-agent"
  end
  # build image and start the application
  config.vm.provision "docker" do |d|
    d.build_image "/vagrant", args: "-t prison-visits"
    d.run "prison-visits",
      args: "-v /vagrant:/usr/src/app -e BUNDLE_FROZEN=0 -p #{UNICORN_PORT}:#{UNICORN_PORT}",
      cmd: "bundle exec rails server"
  end
  # print out help
  config.vm.provision "shell", inline: <<-EOF
    echo "---------------------------------------"
    echo "export DOCKER_HOST=tcp://localhost:2376"
  EOF
  
end
