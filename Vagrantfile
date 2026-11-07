Vagrant.configure("2") do |config|
  # Imagen base: Ubuntu Server 22.04 LTS (Jammy)
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "AmparoPrestashop"
  config.vm.boot_timeout = 600

  # Red privada y reenvio de puertos (HTTP y HTTPS)
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true

  # Configuracion de VirtualBox
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.name = "AmparoPrestashop"
    vb.memory = "2048"
    vb.cpus = 1
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
    vb.customize ["modifyvm", :id, "--uart1", "off"]
  end

  # Aprovisionamiento automatico con los scripts de Bash
  config.vm.provision "shell", path: "scripts/install_lamp.sh"
  config.vm.provision "shell", path: "scripts/setup_letsencrypt_https.sh"
  config.vm.provision "shell", path: "scripts/deploy_prestashop.sh"
end