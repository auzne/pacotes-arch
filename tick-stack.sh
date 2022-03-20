#!/bin/bash

# Instala o TICK Stack
# O pacote sudo é necessário
# para instalar grafana em vez de chronograf, execute o comando com o argumento grafana
# exemplo: ./tick-stack.sh grafana

checagem () {
    existe=$(pacman -Qs $1)
    if [ "$existe" = "" ]
    then
        return 0
    else
        return 1
    fi
}

instalar () {
    pacote=$1
    checagem $pacote
    if [ $? -eq 0 ]
    then
        git clone https://aur.archlinux.org/$pacote.git
        cd $pacote
        makepkg --noconfirm --clean --install --syncdeps --rmdeps
        cd ..
        sudo rm -r $pacote
    else
        echo "Ignorando pacote já instalado: $pacote"
    fi
}

chronograf () {
    # instala o chronograf
    instalar "chronograf-bin"
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
    instalar "telegraf-bin"

    # instala o kapacitor
    instalar "kapacitor-bin"

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
