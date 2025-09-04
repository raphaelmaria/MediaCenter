#!/usr/bin/bash

# INSTALAÇÃO DO MEDIA CENTER DOWNLOAD NO ARM64 (Raspberry Pi OS 64 bits)

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
curl -o  | sudo bash

# Instalando Sonarr
curl | sudo bash

# Instalando Prowlarr
curl | sudo bash

# Instalando QBittorrent
curl | sudo bash

# Instalando o Flaresolverr
curl | sudo bash

# Instalando e configurando o Nginx
curl | sudo bash



