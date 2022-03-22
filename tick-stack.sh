#!/bin/bash

# Instala o TICK Stack
# O pacote sudo é necessário

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
}

grafana () {
    # instala o grafana
    sudo pacman -S --needed --noconfirm grafana
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

    echo "Selecione um pacote para instalar"
    echo "1) chronograf 2) grafana"
    read -p "Digite um número (padrão=1): " corg

    if [ $corg -eq 2 ]
    then
        grafana
    else
        if [ $corg -ne 1 ]
        then
            echo "Instalando o pacote padrão"
        fi
        chronograf
    fi

    echo "Deseja ativar os serviços dos pacotes baixados? [S/n]"
    read iniciar

    if [ $iniciar = "S" ] || [ $iniciar = "s" ]
    then
        # inicia os services
        sudo systemctl enable telegraf.service
        sudo systemctl enable influxdb.service
        sudo systemctl enable kapacitor.service
        if [ $corg -eq 2 ]
        then
            sudo systemctl enable grafana.service
        else
            sudo systemctl enable chronograf.service
        fi
        echo "Reinicia o sistema para iniciar os serviços."
    fi
fi
