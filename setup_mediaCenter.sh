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
curl -fsSL https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_radarr.sh | sed 's/\r$//' | sudo bash

# Instalando Sonarr
curl -fsSL 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_sonarr.sh' | sed 's/\r$//' | sudo bash

# Instalando Prowlarr
curl -fsSL 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_prowlarr.sh' | sed 's/\r$//' | sudo bash

# Instalando QBittorrent
curl -fsSL 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_qbitorrent.sh' | sed 's/\r$//' | sudo bash

# Instalando o Flaresolverr
curl -fsSL 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_flaresolverr.sh' | sed 's/\r$//' | sudo bash

# Instalando e configurando o Nginx
curl -fsSL 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_nginx.sh' | sed 's/\r$//' | sudo bash

# Instalando o Fail2Ban
curl -fsSL 'https://rmtechfiles.s3.us-east-1.amazonaws.com/mediaCenter/ubuntu_install_fail2ban.sh' | sed 's/\r$//' | sudo bash

