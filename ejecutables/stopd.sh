#!/bin/bash

#GRUPO=~/grupo05

#    CONFIG="$GRUPO/dirconf/config.cnf"
#    export BINARIOS=`grep -A 0 BINARIOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`

#source $BINARIOS/inicializaciones.sh



#export GRUPO5_MAESTRO_DE_BANCOS="maestro_de_bancos.csv"

PID=$(cat /tmp/daemon.pid )

kill -9 $PID

echo " stop PID: $PID .. "

rm tmp/daemon.pid > /dev/null
