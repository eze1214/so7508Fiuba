#!/bin/bash
SRV="daemon"
SERV=$(ps -e |grep ${SRV} |awk '{print $1}')

if [ ${SERV} ]; then
#    PID=$(cat /tmp/daemon.pid )
    echo "El demonio está en ejecución, PID: ${SERV}"
    exit 3
fi

$BINARIOS/daemon.sh & 

SERV=$(ps -e |grep ${SRV} |awk '{print $1}')
# Leyendo el archivo obtengo el PID --> así es mucho más facil matarlo
#PID=$(cat /tmp/daemon.pid)

echo -e ".. Demonio Corriendo ..  PID: ${SERV}"
