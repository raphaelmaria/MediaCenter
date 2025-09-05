#!/bin/bash

### INSTALAÇÃO DO NGINX E CONFIGURAÇÃO DO PORTAL MEDIAHUB ###
# Criado por Raphael Oliveira
# Data: 2024-06-26
# Versão: 1.0

### VARIAVEIS ###
$SCRIPT_PATH="/opt/mediacenter/scripts"
### FIM DAS VARIAVEIS ###

cat << EOF | sudo tee /var/www/mediahub/index.html > /dev/null
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Media Center</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #0d1117;
      color: #c9d1d9;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }
    h1 {
      margin: 20px 0;
      font-size: 2.2rem;
      color: #58a6ff;
    }
    .apps {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 25px;
      width: 90%;
      max-width: 900px;
    }
    .app {
      background: #161b22;
      border-radius: 12px;
      padding: 20px;
      text-align: center;
      text-decoration: none;
      color: #c9d1d9;
      transition: transform 0.2s ease, background 0.3s ease;
      box-shadow: 0 4px 8px rgba(0,0,0,0.3);
    }
    .app:hover {
      background: #21262d;
      transform: scale(1.05);
    }
    .app img {
      max-width: 80px;
      margin-bottom: 12px;
    }
    footer {
      margin-top: 40px;
      font-size: 0.8rem;
      color: #8b949e;
    }
  </style>
</head>
<body>
  <h1>🎬 Media Center</h1>
  <div class="apps">
    <a class="app" href="http://127.0.0.1:7878" target="_blank">
      <img src="https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/radarr-icon.png" alt="Radarr">
      <div>Radarr</div>
    </a>
    <a class="app" href="http://127.0.0.1:8989" target="_blank">
      <img src="https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/sonarr-icon.png" alt="Sonarr">
      <div>Sonarr</div>
    </a>
    <a class="app" href="http://127.0.0.1:9117" target="_blank">
      <img src="https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/jackett-icon.png" alt="Jackett">
      <div>Jackett</div>
    </a>
    <a class="app" href="http://127.0.0.1:9696" target="_blank">
      <img src="https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/prowlarr-logo.png" alt="Prowlarr">
      <div>Prowlarr</div>
    </a>
  </div>

  <footer>
    &copy; 2025 Raphael Maria - Todos os direitos reservados.
  </footer>
</body>
</html>
EOF

# Atualiza os repositórios e instala o Nginx
sudo apt update
sudo apt -y full-upgrade
sudo apt -y install -f
sudo apt install nginx -y

sudo mkdir -p /var/www/mediahub
sudo chown -R $USER:$USER /var/www/mediahub


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

cat << EOF | sudo tee /opt/mediacenter/scripts/update_mediahub.sh > /dev/null
#!/bin/bash
HTML="/var/www/mediahub/index.html"
IP=$(hostname -I | awk '{print $1}')

sed -i "s|http://[0-9\.]*:7878|http://$IP:7878|g" $HTML
sed -i "s|http://[0-9\.]*:8989|http://$IP:8989|g" $HTML
sed -i "s|http://[0-9\.]*:9117|http://$IP:9117|g" $HTML
sed -i "s|http://[0-9\.]*:9696|http://$IP:9696|g" $HTML
EOF

# Garantir que a linha do cron não seja duplicada
( sudo crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "0 * * * * $SCRIPT_PATH" ) | sudo crontab -

echo "✅ Script instalado em $SCRIPT_PATH e cron configurado para rodar a cada 1 hora."


# Permissão de execução
sudo chmod +X /opt/mediacenter/scripts/update_mediahub.sh
sudo bash /opt/mediacenter/scripts/update_mediahub.sh

# O Nginx foi instalado e o portal MediaHub está disponível.
# Para acessar o portal, abra o navegador e digite http://$IP
exit