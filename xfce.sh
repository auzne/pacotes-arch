#!/bin/bash

# Instala o gnome
# O pacote sudo é necessário

# instala os pacotes
sudo pacman -Syu --needed --noconfirm xorg xorg-server xfce4 xfce4-goodies lightdm
# coloca como padrão graphical.target caso o usuário tenha desativado
sudo systemctl set-default graphical.target
# ativa o lightdm
sudo systemctl enable lightdm
# reinicia o sistema
sudo restart
