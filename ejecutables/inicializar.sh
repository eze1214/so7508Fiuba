#!/bin/bash


configFile(){

    CONFIG="$GRUPO/dirconf/config.cnf"

    if [ ! -f $CONFIG ]; then 
        echo -e "Error grave! No está presente el archivo de configuración "
        exit 99
    fi
}

setVariables(){

    export GRUPO=`grep -A 0 GRUPO $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable GRUPO: $GRUPO "
    
    export BINARIOS=`grep -A 0 BINARIOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable BINARIOS: $BINARIOS "

    export MAESTROS=`grep -A 0 MAESTROS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable MAESTROS: $MAESTROS "
    
    export NOVEDADES=`grep -A 0 NOVEDADES $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable NOVEDADES: $NOVEDADES "
    
    export ACEPTADOS=`grep -A 0 ACEPTADOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable ACEPTADOS: $ACEPTADOS "
    
    export RECHAZADOS=`grep -A 0 RECHAZADOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable RECHAZADOS: $RECHAZADOS "
    
    export VALIDADOSDIR=`grep -A 0 VALIDADOSDIR $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable VALIDADOSDIR: $VALIDADOSDIR "
    
    export REPORTESDIR=`grep -A 0 REPORTESDIR $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable REPORTEDIR: $REPORTESDIR "
    
    export LOG=`grep -A 0 LOG $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable LOG: $LOG "
    
    export MAESTRO_DE_BANCOS="maestro_de_bancos.csv"
    echo -e ".... Estableciendo la variable MAESTRO_DE_BANCOS: $GRUPO5_MAESTRO_DE_BANCOS "
    
}


startDaemon(){
    $BINARIOS/startd.sh    
    # Intento eliminar el archivo temporal en el cual voy a guardar la pid del demonio
#    rm /tmp/daemon.pid 2> /dev/null
#    
    # Corro el demonio en segundo plano y además gurdo PID en el archivo 
  #  $BINARIOS/daemon.sh > /dev/null 2> /dev/null & echo $! >> /tmp/daemon.pid
#    $BINARIOS/daemon.sh & echo $! >> /tmp/daemon.pid
#    
    # Leyendo el archivo obtengo el PID --> así es mucho más facil matarlo
#    PID=$(cat /tmp/daemon.pid)
#           
#    echo -e ".. Demonio Corriendo ..  PID: $PID"
}



showHelp(){
    echo -e "Uso: inicializar.sh [OPCION..] 
            OPCIONES:
                -d          Iniciar el demonio en forma automática
                -h          Muestra Ayuda
            
            Administrar ejecución de Demonio:
            startd.sh       Iniciar demonio (si aún no lo hace)
            stopd.sh        Detener demonio "
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



inicializarSistema(){
    echo -e "..Abriendo el archivo de configuración"
    configFile

    echo -e "..Generando Variables de ambiente"
    setVariables
    echo -e "...Inicialización realizada ...."

    echo -e "..Estableciendo permisos "
    source $BINARIOS/permisos.sh
}


clear
echo -e "=============================================="
echo -e " Inicialización de Sistema "
echo -e "==============================================\n"


if [ -z $GRUPO ]; then 
    GRUPO=~/grupo05
fi


if [ $# = 0 ]; then 
    inicializarSistema
    default
elif [ $1 == "-d" ]; then
    inicializarSistema
    startDaemon
elif [ $1 == "-h" ]; then
    showHelp
else
    echo -e "Parámetro ingresado inexistente"
    inicializarSistema 
    default 
fi




