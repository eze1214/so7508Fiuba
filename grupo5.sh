#!/bin/bash
#

clear
echo -e "=============================================="
echo -e " Trabajo Práctico Sistemas operativos Grupo 5"
echo -e "==============================================\n"

# Echo defino el archivo de configuración 
CONFDIR="$PWD/dirconf/config.cnf"

# Comprobar existencia de archivo configuración
valConfigFile () {
    if [ ! -f $CONFDIR ]; then
        echo "Error al encontrar archivo de configuración en $CONFDIR" >&2
        exit 1
    fi
}

#Exporta todas las variables obtenidas del archivo de configuración
exportVariables(){
    # Utilizo lo generado en global.sh porque es mucho más claro y mejor
    export GRUPO=`grep -A 0 GRUPO $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export BINARIOS=`grep -A 0 BINARIOS $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export MAESTROS=`grep -A 0 MAESTROS $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export NOVEDADES=`grep -A 0 NOVEDADES $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export ACEPTADOS=`grep -A 0 ACEPTADOS $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export RECHAZADOS=`grep -A 0 RECHAZADOS $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export VALIDADOSDIR=`grep -A 0 VALIDADOSDIR $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export REPORTESDIR=`grep -A 0 REPORTESDIR $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    export LOG=`grep -A 0 LOG $CONFDIR | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`

    if [ -z $GRUPO ] || [ -z $BINARIOS ] || [ -z $MAESTROS ] \
      || [ -z $NOVEDADES ] || [ -z $ACEPTADOS ] || [ -z $RECHAZADOS ] \
      || [ -z $VALIDADOSDIR ] || [ -z $REPORTESDIR ] || [ -z $LOG ]; then 
        echo -e "Error! variables globales inexistentes" >&2
        exit 2
    fi    
}
            

startDaemon(){
    echo -e "TODO: Agregar inicio demonio "
}



showHelp(){
    echo -e "Uso: sisop [OPCION..] \n
                -d          iniciar el demonio en forma automática"
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
        echo " Explicar modo de ejecutar demonio desde start"
    fi
}



# Línea principal 

echo -e "..Leyendo archivo de configuración"
valConfigFile

echo -e "..Generando Variables de ambiente"
exportVariables

echo -e "..Estableciendo permisos correctamente"
bash ./permisos.sh
if [ $? -gt 1 ]; then
    exit 3
fi



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
