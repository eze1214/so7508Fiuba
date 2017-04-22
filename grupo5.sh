#!/bin/bash
#
# TODO: Setear variables PATH y de los archivos según archivo de configuración
clear
echo -e "\nTrabajo Práctico Sistemas operativos Grupo 5\n"

# Echo defino el archivo de configuración 
CONFIG="$PWD/dirconf/config.cnf"

# Comprobar existencia de archivo configuración
valConfigFile () {
    if [ ! -f $CONFIG ]; then
        echo "Error al encontrar archivo de configuración en $CONFIG"
        exit 1
    fi
    echo -e "Archivo de configuración cargado"
}


# Setear Variables de ambiente 
exportVariable(){
    LINE=$1
    echo "LINE : $LINE"
    NAME=$( echo $LINE | cut -d "=" -f 1 )
    echo "NAME: ${NAME}"
    PATH=$( echo "$LINE" | cut -d "=" -f 2 )
    echo " Cargando Name: $NAME  Path: $PATH "
    export ${NAME}=${PATH}
}

#
#validVariables() {
#    minVars=(GRUPO BINARIOS MAESTROS ACEPTADOS RECHAZADOS VALIDADOS VALIDADOSDIR REPORTESDIR LOG)
#    vars=("${!1}")
#    echo ${vars[@]} 
#    res=${minVars[@]/${vars[@]}}
#    echo "${vars[@]} -> Esto es lo que queda $res"
#}

setVariables(){
    local lines=$( cat $CONFIG )
    
    for LINE in $lines; do 
        NAME=$( echo $LINE | cut -d"=" -f 1 )
        PATH_NAME=$( echo $LINE | cut -d"=" -f 2 )
        echo " Cargando Name: $NAME  Path: $PATH_NAME "
        export ${NAME}=${PATH}
    done
}
            

startDaemon(){
    echo -e "This daemon is running.."
}

showHelp(){
    echo -e "Uso: sisop [OPCION..] \n
                -d          iniciar el demonio en forma automática"
}

initSistema(){
    
    read -p "Desea iniciar el demonio ahora?(S/N): " rp
    while [ $rp != "s" ] && [ $rp != "S" ] && [ $rp != "n" ] && [ $rp != "N" ]
    do
        read -p "Desea iniciar el demonio ahora?(S/N): " rp
    done

    if [ $rp = "s" ] || [ $rp = "S" ]; then
        startDaemon
    fi
}


valConfigFile

echo -e "Setear Variables de Enterno"
setVariables


bash testSisop.sh

if [ $# = 0 ]; then 
    initSistema
elif [ $1 == "-d" ]; then
    startDaemon
elif [ $1 == "-h" ]; then
    showHelp
else
    echo -e "Parámetro ingresado inexistente\n" 
    initSistema 
fi
