#!/usr/bin/bash

# Este é o hash SHA-256 da palavra "MARIO".
# Para gerar o hash de outra palavra, use o comando:
# echo -n "SUA_PALAVRA_AQUI" | sha256sum
SECRET_HASH="7d025b394e339a957223b373415170d19f4a01c36f56c70141f224976451e843"

# Solicita a senha de forma invisível
read -s -p "Digite a senha para continuar: " USER_INPUT

# Pula para uma nova linha depois da entrada
echo

# Gera o hash da entrada do usuário e compara com o hash secreto
USER_HASH=$(echo -n "$USER_INPUT" | sha256sum | awk '{print $1}')

if [[ "$USER_HASH" != "$SECRET_HASH" ]]; then
    echo "Senha incorreta. A instalação foi cancelada."
    echo "Por favor, entre em contato com o criador do script para obter a senha."
    exit 1
fi

echo "Senha correta. Prosseguindo com a instalação..."

# O restante do seu script segue a partir daqui
# ...
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

