Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
  config.vm.box = "debian/bullseye64"
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.provision "shell", path: "provision.sh"
end
