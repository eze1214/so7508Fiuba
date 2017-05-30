#!/bin/bash
CICLO=0
SLEEP_TIME=10s
LOG_DAEMON="$LOG/daemon.log"
VALIDADOR_NAME="$BINARIOS/validacion.sh"


validateFilename(){
  filename="${entry##*/}"
  regex="^[A-Z]{1,19}(_)[0-9]{4}[0-1][0-9][0-3][0-9](.csv)$"

  if [[ "$filename" =~ ^$regex ]]
    then
    #echo "Nombre archivo respeta condición de nombre: $filename"

    banco="$($BINARIOS/extraer_nombre_de_banco.sh $filename)"
    #echo "banco= $banco"
    banco_validado="$($BINARIOS/validar_banco.sh $banco ${lista_de_bancos[@]})"
    if [ "$banco_validado" == "false" ]; then
      $BINARIOS/log.sh -w "Validar Nombre Archivo"  -m "Entidad inválida: $filename" -e $LOG_DAEMON
      return 1
    fi

    fecha="$($BINARIOS/extraer_fecha.sh $filename)"
    fecha_validada="$($BINARIOS/validar_fecha.sh $fecha)"
    if [ "$fecha_validada" == "false" ]; then
      $BINARIOS/log.sh -w "Validar Nombre Archivo"  -m "Fecha inválida: $filename" -e $LOG_DAEMON
      return 2
    fi
  else
    $BINARIOS/log.sh -w "Validar Nombre Archivo"  -m "Nombre de archivo inválido: $entry " -e $LOG_DAEMON
    return 3
  fi
  return 0
}



checkNovedades(){
  for entry in "$NOVEDADES"/*
  do
    if [ -s "$entry" ]; then
      check_file=$(file -0 "$entry" | cut -d $'\0' -f2)
      if [[ $check_file == *"text"* ]]; then
        validateFilename
        if [ $? -eq 0 ]; then
          $BINARIOS/moverArchivos.sh "$entry" $ACEPTADOS
        else
          $BINARIOS/moverArchivos.sh "$entry" $RECHAZADOS
        fi
      else
	$BINARIOS/log.sh -w "Validar Archivo" -m "El archivo $entry no es de texto" -e $LOG_DAEMON
        $BINARIOS/moverArchivos.sh "$entry" $RECHAZADOS
      fi
    else
      $BINARIOS/log.sh -w "Validar Archivo" -m "Archivo vacío: $entry " -e $LOG_DAEMON
      $BINARIOS/moverArchivos.sh "$entry" $RECHAZADOS
    fi
  done
}

lista_de_bancos="$($BINARIOS/cargar_maestro_bancos.sh)"
while true
do
    $BINARIOS/log.sh -w Loop -m "Ciclo número $CICLO " -i $LOG_DAEMON
#	echo "Ciclo = $CICLO"
    numFiles=$(find $NOVEDADES -maxdepth 1 -type f | wc -l )
    #echo "Cantidad de archivos encontrados: $numFiles"
    if [ ${numFiles} -gt 0 ]; then
      checkNovedades
	    
      VALIDADOR_PID=$(ps aux |grep ${VALIDADOR_NAME} |grep -v grep |awk '{print $2}')

      if [ ${VALIDADOR_PID} ]; then
        $BINARIOS/log.sh -w "Llamar validador" -m "invocacion propuesta para el siguiente ciclo" -i $LOG_DAEMON
      else
#	$($BINARIOS/validacion.sh)
	$BINARIOS/log.sh -w "Llamar validador" -m "invocacion del validador" -i $LOG_DAEMON
        $BINARIOS/validacion.sh > /dev/null 2>&1
      fi

    fi

    
    sleep $SLEEP_TIME

    CICLO=$((CICLO + 1))
done
