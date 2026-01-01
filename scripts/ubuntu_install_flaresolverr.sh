#!/bin/bash

sudo apt install xvfb
sudo apt install libatk1.0-0

sudo wget https://github.com/FlareSolverr/FlareSolverr/releases/download/v3.4.0/flaresolverr_linux_x64.tar.gz
sudo tar -xvzf flaresolverr_linux_x64.tar.gz
sudo mv flaresolverr /opt/

cat << EOF | sudo tee /etc/systemd/system/flaresolverr.service > /dev/null
[Unit]
Description=FlareSolverr Daemon
After=syslog.target network.target

[Service]
User={$Whoami}
Group=media
UMask=0002
Type=simple
ExecStart=/opt/flaresolverr/flaresolverr
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable flaresolverr.service
sudo systemctl start flaresolverr.service

