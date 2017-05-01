#!/bin/bash

#GRUPO=~/grupo05

#    CONFIG="$GRUPO/dirconf/config.cnf"
#    export BINARIOS=`grep -A 0 BINARIOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`

#source $BINARIOS/inicializaciones.sh



#export GRUPO5_MAESTRO_DE_BANCOS="maestro_de_bancos.csv"
if [ ! -f /tmp/daemon.pid ]; then
    echo "El demonio NO está corriendo "
    exit 3
fi

PID=$(cat /tmp/daemon.pid )

kill -9 $PID 2> /dev/null

if [ $? -eq 0 ]; then
  echo "..Deteniendo Demonio, PID: $PID .. "
else
  echo "El Demonio NO está corriendo "
fi

rm /tmp/daemon.pid 2> /dev/null
