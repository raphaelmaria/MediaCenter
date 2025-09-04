#!/bin/bash

ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo "Arquitetura detectada: x86_64 (amd64)"
    # comandos de instalação amd64
elif [ "$ARCH" = "aarch64" ]; then
    echo "Arquitetura detectada: ARM64 (aarch64)"
    # comandos de instalação arm64
else
    echo "Arquitetura não suportada: $ARCH"
    exit 1
fi
# Baixando a última versão do Radarr
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
