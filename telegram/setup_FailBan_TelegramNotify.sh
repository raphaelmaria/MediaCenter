#!/bin/bash
set -e

TELEGRAM_TOKEN="SEU_TOKEN_TELEGRAM"
TELEGRAM_CHAT_ID="SEU_CHAT_ID"
PORTS="80,9117,9696,7878,8989,9114"
JAIL_LOG="/var/log/mediacenter-http.log"
JAIL_NAME="mediacenter-http"

apt update
apt install -y fail2ban curl

mkdir -p /etc/fail2ban/filter.d

cat << EOF > /etc/fail2ban/filter.d/${JAIL_NAME}.conf
[Definition]
failregex = ^<HOST> - - .*code (400|404|505), message.*
ignoreregex =
EOF

cat << EOF > /etc/fail2ban/action.d/telegram.conf
[Definition]
actionstart = curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Fail2Ban iniciado"
actionstop = curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="Fail2Ban parado"
actionban = curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="IP <ip> BANIDO em $JAIL_NAME"
actionunban = curl -s -X POST https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage -d chat_id=$TELEGRAM_CHAT_ID -d text="IP <ip> DESBANIDO de $JAIL_NAME"
EOF

cat << EOF > /etc/fail2ban/action.d/blacklist.conf
[Definition]
actionban = echo "<ip>" >> /etc/fail2ban/ip_blacklist.txt
actionunban = sed -i "/<ip>/d" /etc/fail2ban/ip_blacklist.txt
EOF

cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
banaction = iptables-multiport
backend = auto
action = %(action_)s
         telegram[name=Fail2BanTelegram, dest=$TELEGRAM_CHAT_ID, token=$TELEGRAM_TOKEN]
         blacklist

[$JAIL_NAME]
enabled = true
filter = $JAIL_NAME
logpath = $JAIL_LOG
maxretry = 2
findtime = 300
bantime = 3600
port = $PORTS
EOF

systemctl restart fail2ban
echo "[✓] Fail2Ban configurado com sucesso com notificações via Telegram!"
