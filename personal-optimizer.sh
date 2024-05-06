#!/bin/bash


clear

# Green, Yellow & Red Messages.
green_msg() {
    tput setaf 2
    echo "[*] ----- $1"
    tput sgr0
}

yellow_msg() {
    tput setaf 3
    echo "[*] ----- $1"
    tput sgr0
}

red_msg() {
    tput setaf 1
    echo "[*] ----- $1"
    tput sgr0
}


# Update Packages
update_packages() {
  echo 
  yellow_msg 'Updating Packages...'
  echo 
  sleep 0.5
  
  sudo apt update && sudo apt upgrade -y

  echo
  green_msg 'Packages Updated.'
  echo 
  sleep 0.5
}

# Blocking IR 
block_ir() {
  echo 
  yellow_msg 'Blocking Iran...'
  echo 
  sleep 0.5
  
  bash <(wget -qO- raw.githubusercontent.com/AliDbg/IPBAN/main/ipban.sh) -add OUTPUT -geoip IR -limit DROP -icmp NO

  echo
  green_msg 'Iran Blocked.'
  echo 
  sleep 0.5
}

# Setting SSH Port 1371 
change_ssh_port() {
  echo 
  yellow_msg 'Changing SSH Port...'
  echo 
  sleep 0.5
  
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bk
  sudo echo "Port 1371" >> /etc/ssh/sshd_config
  sudo ufw allow 1371/tcp
  sudo systemctl restart sshd

  echo
  green_msg 'SSH Port Changed.'
  echo 
  sleep 0.5
}

# Caddy prerequisites
caddy_prerequisites(){
  echo 
  yellow_msg 'Caddy prerequisites...'
  echo 

  sudo mkdir /home/tls
  sudo mkdir -p /var/www/html
  sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list && sudo apt update && sudo apt install caddy
  sudo wget "https://raw.githubusercontent.com/zoheirkabuli/personal-optimizer/main/caddy.json"
  sudo wget "https://github.com/zoheirkabuli/soon-site/releases/download/v1.0.4/web.zip"
  unzip web.zip -d /var/www/html/
  sudo mv /var/www/html/out/* /var/www/html/
  sudo rm web.zip

  echo
  green_msg 'Caddy prerequisites installed.'
  echo 
  sleep 0.5
}

# UFW Rules
ufw_rules() {
  echo 
  yellow_msg 'Setting UFW Rules...'
  echo 
  sleep 0.5
  
  sudo ufw allow 21 && sudo ufw allow 21/udp && sudo ufw allow 80 && sudo ufw allow 80/udp && sudo ufw allow 8080 && sudo ufw allow 8080/udp && sudo ufw allow 443 && sudo ufw allow 443/udp && sudo ufw allow 2053 && sudo ufw allow 2053/udp && sudo ufw allow 2083 && sudo ufw allow 2083/udp && sudo ufw allow 2087 && sudo ufw allow 2087/udp && sudo ufw allow 2096 && sudo ufw allow 2096/udp && sudo ufw allow 8443 && sudo ufw allow 8443/udp

  sudo ufw allow http  && sudo ufw allow https && sudo ufw allow 8443 && sudo ufw allow 8443/udp

  echo
  green_msg 'UFW Rules Set.'
  echo 
  sleep 0.5
}

# Enabling UFW
enable_ufw() {
  echo 
  yellow_msg 'Setting UFW Rules...'
  echo 
  sleep 0.5
  
  sudo systemctl enable ufw
  echo "y" | sudo ufw enable

  echo
  green_msg 'UFW Rules Set.'
  echo 
  sleep 0.5
}

# Reboot
reboot() {
  echo 
  yellow_msg 'Reboot in 3 Seconds...'
  echo 
  sleep 3
  
  shutdown -r 0 
}


update_packages
caddy_prerequisites
change_ssh_port
ufw_rules
enable_ufw
reboot
