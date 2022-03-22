#!/bin/bash

# Instala o gnome
# O pacote sudo é necessário

# instala os pacotes
sudo pacman -Syu --needed --noconfirm xorg xorg-server xfce4 xfce4-goodies gdm
# coloca como padrão graphical.target caso o usuário tenha desativado
sudo systemctl set-default graphical.target
# ativa o gdm
sudo systemctl enable gdm
# reinicia o sistema
sudo restart
