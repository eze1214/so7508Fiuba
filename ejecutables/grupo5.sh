#!/bin/bash
#

clear
echo -e "=============================================="
echo -e " Trabajo Práctico Sistemas operativos Grupo 5"
echo -e "==============================================\n"

# Echo defino el archivo de configuración 
GRUPO=~/grupo05

    CONFIG="$GRUPO/dirconf/config.cnf"
    export BINARIOS=`grep -A 0 BINARIOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`

source $BINARIOS/inicializaciones.sh
            

startDaemon(){    
    # Intento eliminar el archivo temporal en el cual voy a guardar la pid del demonio
    rm /tmp/daemon.pid 2> /dev/null
    
    # Corro el demonio en segundo plano y además gurdo PID en el archivo 
   # $BINARIOS/daemon.sh > /dev/null 2> /dev/null & echo $! >> /tmp/daemon.
    export GRUPO5_MAESTRO_DE_BANCOS="maestro_de_bancos.csv"
    $BINARIOS/daemon.sh  & echo $! >> /tmp/daemon.pid
    
    # Leyendo el archivo obtengo el PID --> así es mucho más facil matarlo
    PID=$(cat /tmp/daemon.pid)
           
    echo -e ".. Demonio Corriendo ..  PID: $PID"
}



showHelp(){
    echo -e "Uso: grupo5.sh [OPCION..] \n
                -d          iniciar el demonio en forma automática
            
            Otras formas de ejecutar demonio
            --------------------------------
            
            start      "
}



default(){
    echo -e "\n====== "
    read -p "Desea iniciar el demonio ahora?[S/N]: " rp
    
    while [ $rp != "s" ] && [ $rp != "S" ] && [ $rp != "n" ] && [ $rp != "N" ]
    do
        read -p "Desea iniciar el demonio ahora?(S/N): " rp
    done

    if [ $rp = "s" ] || [ $rp = "S" ]; then
        startDaemon
    else
        showHelp
    fi
}



# Línea principal 



if [ $# = 0 ]; then 
    default
elif [ $1 == "-d" ]; then
    startDaemon
elif [ $1 == "-h" ]; then
    showHelp
else
    echo -e "Parámetro ingresado inexistente\n" 
    default 
fi
