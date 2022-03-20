#!/bin/bash

# Instala o TICK Stack
# para instalar grafana em vez de chronograf, execute o comando com o argumento grafana
# exemplo: ./tick-stack.sh grafana

instalar () {
    pacote=$1
    cd $pacote
    makepkg --noconfirm --clean --install --syncdeps --rmdeps
    cd ..
    rm -r $pacote
}

chronograf () {
    # instala o chronograf
    git clone https://aur.archlinux.org/chronograf-bin.git chronograf
    instalar "chronograf"
    systemctl enable --now chronograf.service
}

grafana () {
    # instala o grafana
    pacman -S --needed --noconfirm grafana
    systemctl enable --now grafana.service
}

if [ $(whoami) = "root" ]
then
    # instala o git (para os pacotes no aur) e o influxdb
    pacman -Sy --needed --noconfirm git influxdb

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
    systemctl enable --now telegraf.service
    systemctl enable --now influxdb.service
    systemctl enable --now kapacitor.service

else
    echo "Você não pode realizar esta operação a menos que seja root"
fi
