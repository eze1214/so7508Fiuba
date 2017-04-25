

if [ -z $GRUPO ]; then 
    GRUPO=~/grupo05
fi


echo -e "..Abriendo el archivo de configuración: $CONFIG "

if [ -z $CONFIG ]; then 
    CONFIG="$GRUPO/dirconf/config.cnf"
fi

if [ ! -f $CONFIG ]; then 
    echo -e "Error grave! No está presente el archivo de configuración "
    exit 99
fi


echo -e "..Generando Variables de ambiente"

if [ -z $GRUPO ]; then
    export GRUPO=`grep -A 0 GRUPO $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable GRUPO: $GRUPO "
fi

if [ -z $BINARIOS ]; then
    export BINARIOS=`grep -A 0 BINARIOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable BINARIOS: $BINARIOS "
fi

if [ -z $MAESTROS ]; then
    export MAESTROS=`grep -A 0 MAESTROS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable MAESTROS: $MAESTROS "
fi

if [ -z $NOVEDADES ]; then
    export NOVEDADES=`grep -A 0 NOVEDADES $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable NOVEDADES: $NOVEDADES "
fi

if [ -z $ACEPTADOS ]; then
    export ACEPTADOS=`grep -A 0 ACEPTADOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable ACEPTADOS: $ACEPTADOS "
fi

if [ -z $RECHAZADOS ]; then
    export RECHAZADOS=`grep -A 0 RECHAZADOS $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable RECHAZADOS: $RECHAZADOS "
fi

if [ -z $VALIDADOSDIR ]; then
    export VALIDADOSDIR=`grep -A 0 VALIDADOSDIR $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable VALIDADOSDIR: $VALIDADOSDIR "
fi

if [ -z $REPORTESDIR ]; then
    export REPORTESDIR=`grep -A 0 REPORTESDIR $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable REPORTEDIR: $REPORTESDIR "
fi

if [ -z $LOG ]; then
    export LOG=`grep -A 0 LOG $CONFIG | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
    echo -e ".... Estableciendo la variable LOG: $LOG "
fi



echo ".... Inicialización realizada ...."
