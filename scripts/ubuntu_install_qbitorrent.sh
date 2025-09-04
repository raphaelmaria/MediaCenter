#!/usr/bin/bash

sudo apt -y install qbittorrent-nox

sudo adduser --system --group qbittorrent-nox

cat << EOF | sudo tee /etc/systemd/system/qbittorrent-nox.service > /dev/null
[Unit]
Description=qBittorrent NoX Terminal Application
After=network.target

[Service]
Type=forking
User=qbittorrent-nox
Group=qbittorrent-nox
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

sudo systemctl enable --now qbittorrent-nox
sudo sstemctl start qbittorrent-noxy

'''
Para acessar o qBittorrent, abra o navegador e digite:
http://localhost:8080
Usuário padrão: admin
Senha padrão: adminadmin
'''
exit (0)

#
