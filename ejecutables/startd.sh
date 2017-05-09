#!/bin/bash
SRV="$BINARIOS/daemon.sh"
SERV=$(ps aux |grep ${SRV} |grep -v grep |awk '{print $2}')

if [ ${SERV} ]; then
#    PID=$(cat /tmp/daemon.pid )
    echo "El demonio está en ejecución, PID: ${SERV}"
    exit 3
fi

$BINARIOS/daemon.sh & 

SERV=$(ps aux |grep ${SRV} |awk '{print $2}')
# Leyendo el archivo obtengo el PID --> así es mucho más facil matarlo
#PID=$(cat /tmp/daemon.pid)

echo -e ".. Demonio Corriendo ..  PID: ${SERV}"
