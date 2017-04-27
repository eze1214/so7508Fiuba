#!/bin/bash

#GRUPO=~/grupo05

#    CONFIG="$GRUPO/dirconf/config.cnf"
#    export BINARIOS=`grep -A 0 BINARIOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`

#source $BINARIOS/inicializaciones.sh


if [ -f /tmp/daemon.pid ]; then
    echo "El demonio ya existe"
    exit 3
fi

#export GRUPO5_MAESTRO_DE_BANCOS="maestro_de_bancos.csv"
`$BINARIOS/daemon.sh  & echo $! >> /tmp/daemon.pid`

