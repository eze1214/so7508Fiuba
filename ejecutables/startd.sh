#!/bin/bash


if [ -f /tmp/daemon.pid ]; then
    PID=$(cat /tmp/daemon.pid )
    echo "El demonio está en ejecución, PID: $PID"
    exit 3
fi

$BINARIOS/daemon.sh  & echo $! >> /tmp/daemon.pid

# Leyendo el archivo obtengo el PID --> así es mucho más facil matarlo
PID=$(cat /tmp/daemon.pid)

echo -e ".. Demonio Corriendo ..  PID: $PID"
