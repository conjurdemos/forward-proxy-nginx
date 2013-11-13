# vi: set ft=ruby :


# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'
  #config.vm.provision "shell", inline: $script
  config.vm.provision "shell", path: "provision.sh"
  config.vm.synced_folder '.', '/home/vagrant'
  config.vm.network :forwarded_port, host: 9080, guest: 80
end
