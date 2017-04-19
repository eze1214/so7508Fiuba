#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	5			#
#	Nombre:	loguearT.sh			#
#					#
#########################################

#########################################
# + Opciones y Parámetros
# •Comando
# •Tipo de Mensaje y Mensaje
# •Para el caso de instalar se usa un cuarto parámetro, donde se especifica la ruta del archivo de log
# + El servicio que brinda esta función es la escritura en los archivos de log de los mensajes
# pasados como parámetro por los consumidores de este servicio.
# + Se crea a los efectos de estandarización de los mensajes de error y para homogeneizar la
# lectura/escritura de los mismos.
# + Puede ser invocado desde la línea de comando o bien desde otro comando.
# +El responsable de este servicio debe gestionar entre sus consumidores la estand
#########################################


# Usage: see below 

#Ayuda
USAGE="USAGE: loguearT command [message_type] message\
       Example: loguearT instalar I INFO: Instalando variables de entorno"

if [ "$1" != "instalar" ] ; then
  source global.sh      
fi

#chequea y trunca si es necesario el archivo en caso de que llegue al tam maximo.
truncate() {

    SIZE=0
    #Obtengo el tamani del archivo, si es que este existe.
    if [ -e "$LOG/$COMMAND.$LOGEXT" ]
    then
          SIZE=`du -sb "$LOG/$COMMAND.$LOGEXT"`
          SIZE=`echo $SIZE | cut -f 1 -d ' '`
    fi

    AUXMAX=`expr $LOGSIZE \* 1024`
    
    #Si es mas grande que el tamani maximo permitido, entonces lo trunco.
    if [ $SIZE -gt $AUXMAX ]
    then
          TOTAL_LINES=`wc -l $LOG/$COMMAND.$LOGEXT | cut -f 1 -d ' '`
          CUTLINES=`expr $TOTAL_LINES \/ 2`
          echo -e "`tail -n $CUTLINES "$LOG/$COMMAND.$LOGEXT"`" > "$LOG/$COMMAND.$LOGEXT"
          echo "$DATE-$USER-I-LOG EXCEEDED." >> "$LOG/$COMMAND.$LOGEXT"
    fi

    return 0
}

#Funcion principal.
#Parametros
#     Parametro 1 (obligatorio): COMMAND
#     Parametro 2 (obligatorio): Tipo de MSG
#     Parametro 3 (obligatorio): MSG
main() {

    COMMAND=$1
    MSGTYPE=$2
    DATE=`date "+%Y%m%d_%H:%M:%S"`
    USER=`whoami`
    
    #Si MSG tiene mas de 140 caracteres lo trunco
    MSG=`echo $3 | sed 's/\(^.\{140\}\).*/\1/'`

    case $COMMAND in

    'instalar')
                #Para cuando el COMMAND sea instalar el log va al directorio default segun enunciado: LOG
                echo "$DATE-$USER-$COMMAND-$MSGTYPE-$MSG." >> "$4";;
    *)
                #Trunco el archivo en caso de que sea mas grande que lo permitido.
                truncate
                #Escribo en el log.
		# Debug> 
		#echo "$DATE-$USER-$COMMAND-$MSGTYPE-$MSG."
		#echo "$LOG/$COMMAND.$LOGEXT"
                echo "$DATE-$USER-$COMMAND-$MSGTYPE-$MSG." >> "$LOG/$COMMAND.$LOGEXT";;
    esac
}

# Si no existe el directorio destino del log usa el default
if [ -z $LOG ] ; then
   LOG="$GRUPO/logdir"
fi

# Chequea que la variable logdir sea un directorio valido (salvo en el caso de la instalacion)
if [ ! -d "$LOG" ] && [ ! $1 == "instalar" ] ; then
	echo "No existe el directorio destino de los logs"
	exit 1
fi

# Si no existe la extension del log usa la default
if [ -z $LOGEXT ] ; then
   LOGEXT=log
fi

# El tam max del log debe ser definido
if [ -z $LOGSIZE ] && [ ! $1 == "instalar" ] ; then
   echo "No esta definido el tamanio de log [$LOGSIZE]"
   exit 1
fi 


# En el caso de instalar emplea el directorio pasado en el parametro $4
if [ "$1" == "instalar" ] ; then
   # No hago el echo, porque sino me sale cada vez que lo llamo
   # echo "Para el comando 'instalar' se emplea la ruta de archivo de log $4"
   main "$1" "$2" "$3" "$4"
fi

#Tiene que tener tres parametros obligatoriamente.
if [ $# \< 3 ] || [ $# \> 3 ]; then
  if [ "$1" != "instalar" ] ; then
    echo $USAGE
    exit 2
  fi
fi

if [ "$1" != "instalar" ] ; then
  main "$1" "$2" "$3"
fi

exit 0