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
    
    LOG_INIC="$LOG/inic.log"
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable GRUPO: $GRUPO " -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable BINARIOS: $BINARIOS" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable MAESTROS: $MAESTROS" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable NOVEDADES: $NOVEDADES" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable ACEPTADOS: $ACEPTADOS" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable RECHAZADOS: $RECHAZADOS" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable VALIDADOSDIR: $VALIDADOSDIR" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Etableciendo la variable REPORTEDIR: $REPORTESDIR" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable LOG: $LOG" -i $LOG_INIC
    $BINARIOS/log.sh -w "Variables Ambiente"  -m "Estableciendo la variable MAESTRO_DE_BANCOS: $GRUPO5_MAESTRO_DE_BANCOS" -i $LOG_INIC

}


startDaemon(){
    $BINARIOS/startd.sh    
    $BINARIOS/log.sh -w "Comando Startd"  -m "Resultado: $?" -i $LOG_INIC
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

    $BINARIOS/log.sh -w "Inicio Demonio"  -m "Desea iniciar el demonio ahora?(S/N): $rp " -i $LOG_INIC
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
    $BINARIOS/log.sh -w "Permisos"  -m "Estableciendo Permisos " -i $LOG_INIC
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
    $BINARIOS/log.sh -w "Parámetros"  -m "Sin parámetros ingresados " -i $LOG_INIC
    default
elif [ $1 == "-d" ]; then
    inicializarSistema
    $BINARIOS/log.sh -w "Parámetros"  -m "Parámetro ingresado \"-d\" - Inicia demonio por default " -i $LOG_INIC
    startDaemon
elif [ $1 == "-h" ]; then
    showHelp
else
    echo -e "Parámetro ingresado inexistente"
    inicializarSistema 
    $BINARIOS/log.sh -w "Parámetros"  -m "Parámetro ingresado inexistente" -i $LOG_INIC
    default 
fi




