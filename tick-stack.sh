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

if [ $(whoami) = "root" ]
then
    echo "Você não pode realizar esta operação como root"
else
    echo "Selecione o tipo dos pacotes a serem instalados"
    echo "1) versão binária"    # não há necessidade de compilar
    echo "2) código fonte"      # é necessário compilar
    read -p "Digite um número (padrão=1): " tipo

    telegraf="telegraf"
    kapacitor="kapacitor"
    chronograf="chronograf"
    if [ "$tipo" = "2" ]
    then
        # dependencias de compilação
        sudo pacman -S --needed --noconfirm go gcc
    else
        telegraf="$telegraf-bin"
        kapacitor="$kapacitor-bin"
        chronograf="$chronograf-bin"
    fi

    # instala o git, fakeroot (para os pacotes no aur) e o influxdb
    sudo pacman -Sy --needed --noconfirm git fakeroot influxdb

    # instala o telegraf
    instalar $telegraf

    # instala o kapacitor
    instalar $kapacitor

    echo
    echo "Selecione um pacote para instalar"
    echo "1) chronograf"
    echo "2) grafana"
    read -p "Digite um número (padrão=1): " corg

    if [ "$corg" = "2" ]
    then
        # instala o grafana
        sudo pacman -S --needed --noconfirm grafana
    else
        # instala o chronograf
        if [ "$corg" != "1" ]
        then
            echo "Instalando o pacote padrão"
        fi
        instalar $chronograf
    fi

    echo "Deseja ativar os serviços dos pacotes instalados? [S/n]"
    read iniciar

    if [ "$iniciar" = "S" ] || [ "$iniciar" = "s" ]
    then
        # inicia os services
        sudo systemctl enable telegraf.service
        sudo systemctl enable influxdb.service
        sudo systemctl enable kapacitor.service
        if [ "$corg" = "2" ]
        then
            sudo systemctl enable grafana.service
        else
            sudo systemctl enable chronograf.service
        fi
        echo "Reinicia o sistema para iniciar os serviços."
    fi
fi
