#!/usr/bin/bash

'''
Script de instalação do Prowlarr no Ubuntu.
Feito por Raphael Oliveira -
https://wiki.servarr.com/prowlarr/installation/linux
'''

ARCH=uname -m
if $ARCH = "x86_64"
then
  echo "Instalando Prowlarr para arquitetura x64"
  wget --content-disposition 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
elif $ARCH = "aarch64"
then
  echo "Instalando Prowlarr para arquitetura ARM64"
  wget --content-disposition 'http://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=arm64'
else
  echo "Arquitetura não suportada: $ARCH"
  exit 1
fi

sudo apt -y install curl sqlite3
tar -xvzf Prowlarr*.linux*.tar.gz
sudo mv Prowlarr/ /opt
sudo mkdir -p /var/lib/prowlarr
sudo adduser --system --group --no-create-home prowlarr
sudo chown prowlarr:prowlarr -R /var/lib/prowlarr
sudo chown prowlarr:prowlarr -R /opt/Prowlarr

cat << EOF | sudo tee /etc/systemd/system/prowlarr.service > /dev/null
[Unit]
Description=Prowlarr Daemon
After=syslog.target network.target
[Service]
User=prowlarr
Group=prowlarr
Type=simple

ExecStart=/opt/Prowlarr/Prowlarr -nobrowser -data=/var/lib/prowlarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl -q daemon-reload
sudo systemctl enable --now -q prowlarr
sudo systemctl start prowlarr.service
