#!/bin/sh

# Instala o gnome
# O pacote sudo é necessário

# instala os pacotes necessários
sudo pacman -Syu --needed --noconfirm xorg xorg-server gnome gnome-tweaks
# coloca como padrão graphical.target caso o usuário tenha desativado
sudo systemctl set-default graphical.target
# ativa o gdm
sudo systemctl enable gdm
# reinicia o sistema
sudo reboot
