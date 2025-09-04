#!/bin/bash

# Caminho do script que atualiza o HTML
SCRIPT_PATH="/usr/local/bin/update_mediahub.sh"

# Criar o script principal
cat << 'EOF' | sudo tee $SCRIPT_PATH > /dev/null
#!/bin/bash
HTML="/var/www/mediahub/index.html"
IP=$(hostname -I | awk '{print $1}')

sed -i "s|http://[0-9\.]*:7878|http://$IP:7878|g" $HTML
sed -i "s|http://[0-9\.]*:8989|http://$IP:8989|g" $HTML
sed -i "s|http://[0-9\.]*:9117|http://$IP:9117|g" $HTML
sed -i "s|http://[0-9\.]*:9696|http://$IP:9696|g" $HTML
EOF

# Permissão de execução
sudo chmod +x $SCRIPT_PATH

# Garantir que a linha do cron não seja duplicada
( sudo crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "0 * * * * $SCRIPT_PATH" ) | sudo crontab -

echo "✅ Script instalado em $SCRIPT_PATH e cron configurado para rodar a cada 1 hora."
