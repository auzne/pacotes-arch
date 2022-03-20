#!/bin/bash

# instala os pacotes necessários
sudo pacman -Syu --needed --noconfirm xorg xorg-server gnome gnome-tweaks
# ativa o serviço gdm
sudo systemctl enable --now gdm.service
