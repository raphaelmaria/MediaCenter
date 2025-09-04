#!/usr/bin/bash

# INSTALAÇÃO DO MEDIA CENTER DOWNLOAD NO ARM64 (Raspberry Pi OS 64 bits)
IP=$(hostname -I | awk '{print $1}')
# Atualiza os repositórios e instala dependências
sudo apt update
sudo apt install -y wget apt-transport-https gnupg2 software-properties-common curl wget vim
sudo apt install -y openjdk-11-jre ffmpeg sqlite3 mediainfo libmono-cil-dev
sudo apt install -y libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libgbm1 libgtk-3-0 libpango-1.0-0 libxcomposite1 libxdamage1 libxrandr2 libasound2 libxtst6 xdg-utils
        
# Criando diretorios necessarios
sudo mkdir -p /opt/mediacenter
sudo mkdir -p /opt/mediacenter/scripts


# Iniciando a instalação do Media Center Download

# Instalando Radarr
curl -O 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_radarr.sh' | sudo bash

# Instalando Sonarr
curl -O 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_sonarr.sh' | sudo bash

# Instalando Prowlarr
curl -O 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_prowlarr.sh' | sudo bash

# Instalando QBittorrent
curl -O 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_qbitorrent.sh' | sudo bash

# Instalando o Flaresolverr
curl -O 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_flaresolverr.sh' | sudo bash

# Instalando e configurando o Nginx
curl -O 'hhttps://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_nginx.sh' | sudo bash

# Instalando o Fail2Ban
curl -O 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_fail2ban.sh' | sudo bash

