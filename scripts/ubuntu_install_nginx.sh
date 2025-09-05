#!/bin/bash

### INSTALAÇÃO DO NGINX E CONFIGURAÇÃO DO PORTAL MEDIAHUB ###
# Criado por Raphael Oliveira
# Data: 2024-06-26
# Versão: 1.0

### VARIAVEIS ###
$SCRIPT_PATH="/opt/mediacenter/scripts"
### FIM DAS VARIAVEIS ###


sudo mkdir -p /var/www/mediahub
sudo chown -R $USER:$USER /var/www/mediahub

# Atualiza os repositórios e instala o Nginx
sudo apt update
sudo apt -y full-upgrade
sudo apt -y install -f
sudo apt install nginx -y



# Configuração da página do portal MediaHub

cat << EOF | sudo tee /etc/nginx/sites-available/mediahub > /dev/null
server {
    listen 80;
    server_name _;

    root /var/www/mediahub;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Configuração do Nginx para servir o portal MediaHub'''

sudo ln -s /etc/nginx/sites-available/mediahub /etc/nginx/sites-enabled/

sudo systemctl enable --now nginx
sudo systemctl start nginx

sudo rm -rf /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx


# Permissão de execução
sudo chmod +X /opt/mediacenter/scripts/update_mediahub.sh
sudo bash /opt/mediacenter/scripts/update_mediahub.sh

# O Nginx foi instalado e o portal MediaHub está disponível.
# Para acessar o portal, abra o navegador e digite http://$IP
