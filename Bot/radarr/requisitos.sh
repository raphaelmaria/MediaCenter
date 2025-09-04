#!/usr/bin/bash

pip install python-telegram-bot requests
sudo mkdir -p /data/movies
sudo chmod -R 750 /data/movies

# Logs
sudo mkdir -p /var/log/radarr-bot
sudo chown raphaelmaria:raphaelmaria /var/log/radarr-bot
sudo chmod 755 /var/log/radarr-bot