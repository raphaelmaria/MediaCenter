#!/bin/bash

ARCH = $(uname -m)
if $ARCH = "x86_64"
then
  echo "Instalando Prowlarr para arquitetura x64"
  wget --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
elif $ARCH = "aarch64"
then
  echo "Instalando Prowlarr para arquitetura ARM64"
  wget --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=arm64'
else
  echo "Arquitetura não suportada: $ARCH"
  exit 1
fi
sudo apt install curl sqlite3
tar -xvzf Radarr*.linux*.tar.gz
sudo mv Radarr /opt/
sudo adduser --system --group --no-create-home radarr
sudo mkdir -p /var/lib/radarr
sudo chown radarr:radarr -R /var/lib/radarr
sudo chown radarr:radarr -R /opt/Radarr

cat << EOF | sudo tee /etc/systemd/system/radarr.service > /dev/null
[Unit]
Description=Radarr Daemon
After=syslog.target network.target
[Service]
User=radarr
Group=radarr
Type=simple

ExecStart=/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl -q daemon-reload
sudo systemctl enable --now -q radarr
