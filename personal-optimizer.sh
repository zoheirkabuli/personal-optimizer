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

# Function to display usage
usage() {
  echo "Usage: $0 -e <email> -d <domain>"
  exit 1
}

# Parse flags
while getopts "e:d:" opt; do
  case ${opt} in
    e)
      email=$OPTARG
      ;;
    d)
      domain=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

# Check if the domain is provided
if [[ -z "$email" || -z "$domain" ]]; then
  echo "Error: Both -e (email) and -d (domain) flags are required."
  usage
fi


# Update Packages
update_packages() {
  echo 
  yellow_msg 'Updating Packages...'
  echo 
  sleep 0.5

  sudo apt update && sudo apt upgrade -y
  sudo apt install unzip -y

  echo
  green_msg 'Packages Updated.'
  echo 
  sleep 0.5
}

# Get SSL
get_ssl() {
  echo 
  yellow_msg 'Getting SSL...'
  echo 
  sleep 0.5

  sudo bash -c "$(curl -sL https://raw.githubusercontent.com/erfjab/ESSL/master/essl.sh)" @ --install
  essl "$email" "$domain" /certs/

  echo
  green_msg 'Getting SSL finished.'
  echo 
  sleep 0.5
}

# Install NGINX
install_nginx() {
  echo 
  yellow_msg 'Installing NGINX...'
  echo 
  sleep 0.5

  sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
  curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
  gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
  http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
  echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx
  sudo apt update
  sudo apt install nginx -y

  echo
  green_msg 'NGINX Installed.'
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
  sudo service ssh restart

  echo
  green_msg 'SSH Port Changed.'
  echo 
  sleep 0.5
}

# Nginx prerequisites
nginx_prerequisites(){
  echo 
  yellow_msg 'Nginx prerequisites...'
  echo 

  sudo mkdir -p /var/www/html
  sudo wget "https://github.com/zoheirkabuli/soon-site/releases/download/v1.0.4/web.zip"
  unzip web.zip -d /var/www/html/
  sudo mv /var/www/html/out/* /var/www/html/
  sudo rm web.zip
  rm -f /etc/nginx/conf.d/default.conf
  curl -fsSL "https://raw.githubusercontent.com/zoheirkabuli/personal-optimizer/refs/heads/main/nginx.conf" -o "/etc/nginx/conf.d/default.conf"

  echo
  green_msg 'Nginx prerequisites installed.'
  echo 
  sleep 0.5
}

# DNS Configuration
dns_configuration() {
    # Remove the /etc/resolv.conf file
    rm -f /etc/resolv.conf

    # Create a new /etc/resolv.conf file with the specified data
    cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
EOF

    # Make /etc/resolv.conf immutable
    chattr +i /etc/resolv.conf

    echo "DNS configuration updated and locked successfully."
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
change_ssh_port
get_ssl
install_nginx
nginx_prerequisites
dns_configuration
reboot
