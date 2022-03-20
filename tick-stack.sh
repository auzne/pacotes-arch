#!/bin/bash

# Instala o TICK Stack
# O pacote sudo é necessário
# para instalar grafana em vez de chronograf, execute o comando com o argumento grafana
# exemplo: ./tick-stack.sh grafana

instalar () {
    pacote=$1
    cd $pacote
    makepkg --noconfirm --clean --install --syncdeps --rmdeps
    cd ..
    sudo rm -r $pacote
}

chronograf () {
    # instala o chronograf
    git clone https://aur.archlinux.org/chronograf-bin.git chronograf
    instalar "chronograf"
    sudo systemctl enable --now chronograf.service
}

grafana () {
    # instala o grafana
    sudo pacman -S --needed --noconfirm grafana
    sudo systemctl enable --now grafana.service
}

if [ $(whoami) = "root" ]
then
    echo "Você não pode realizar esta operação como root"
else
    # instala o git, fakeroot (para os pacotes no aur) e o influxdb
    sudo pacman -Sy --needed --noconfirm git fakeroot influxdb

    # instala o telegraf
    git clone https://aur.archlinux.org/telegraf-bin.git telegraf
    instalar "telegraf"

    # instala o kapacitor
    git clone https://aur.archlinux.org/kapacitor-bin.git kapacitor
    instalar "kapacitor"

    # instala o grafana se foi pedido pelo usuario
    g=0
    if [ $# -gt 0 ]
    then
        if [ $1 = "grafana" ]
        then
            g=1
            grafana
        fi
    fi
    # instala o chronograf se o grafana nao foi instalado
    if [ $g = 0 ]
    then
        chronograf
    fi

    # inicia os services
    sudo systemctl enable --now telegraf.service
    sudo systemctl enable --now influxdb.service
    sudo systemctl enable --now kapacitor.service
fi
