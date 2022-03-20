#!/bin/bash

# Instala o gnome
# O pacote sudo é necessário

# instala os pacotes necessários
sudo pacman -Syu --needed --noconfirm xorg xorg-server gnome gnome-tweaks
# ativa o serviço gdm
sudo systemctl enable --now gdm.service
