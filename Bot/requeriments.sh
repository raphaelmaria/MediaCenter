#!/bin/sh

# Remove a Instalacao atual 
pip uninstall telegram python-telegram-bot -y

# Instala a versao atuaizada
pip install python-telegram-bot --upgrade
