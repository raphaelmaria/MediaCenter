#!/bin/bash
set -e

PORTS="8080,9696,7878,8989,9114"
JAIL_LOG="/var/log/mediacenter.log"
JAIL_NAME="mediacenter"

apt update
apt install -y fail2ban curl

mkdir -p /etc/fail2ban/filter.d

cat << EOF > /etc/fail2ban/filter.d/${JAIL_NAME}.conf
[Definition]
failregex = ^<HOST> - - .*code (400|404|505), message.*
ignoreregex =
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
