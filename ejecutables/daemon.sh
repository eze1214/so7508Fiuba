#!/bin/bash
CICLO=0
SLEEP_TIME=5s
LOG_DAEMON="$LOG/daemon.log"


checkNovedades(){

  for entry in "$NOVEDADES"/*
  do
    filename=${entry##*/}
    filename=${filename%.*}

    regex="^[A-Z]{1,19}(_)[0-9]{4}[0-1][0-9][0-3][0-9]$"
    if [[ $filename =~ ^$regex ]]
      then
      echo "Nombre archivo respeta condición de nombre: $filename"
      banco=$($BINARIOS/extraer_nombre_de_banco.sh $filename)
      banco_validado=$($BINARIOS/validar_banco.sh $banco "${lista_de_bancos[@]}")

      if [ "$banco_validado" == "false" ]
        then
        echo "Error! El banco no existe: $banco"
      fi

      fecha=$($BINARIOS/extraer_fecha.sh $filename)
      fecha_validada=$($BINARIOS/validar_fecha.sh $fecha)

      if [ "$fecha_validada" == "false" ]
        then
        echo "Error! La Fecha no existe: $fecha"
      fi

      if [ "$fecha_validada" == "true" ] && [ "$banco_validado" == "true" ]
        then
        echo "Nombre válido -> a ACEPTADOS la entrada: $entry"
        `$BINARIOS/moverArchivos.sh $entry $ACEPTADOS`
      else
        echo "Banco o Fecha inválidos --> RECHAZADOS la entrada $entry"
        `$BINARIOS/moverArchivos.sh $entry $RECHAZADOS`
      fi
    else
      if [ "$entry" ]
        then
        echo "Error! Nombre archivo NO respeta condición de nombre: $filename"
       `$BINARIOS/moverArchivos.sh $entry $RECHAZADOS`
      fi
    fi
  done
}

lista_de_bancos=$($BINARIOS/cargar_maestro_bancos.sh)
while true
do
    $BINARIOS/loguearT.sh -w Loop -m "Ciclo número $CICLO " -i $LOG_DAEMON
#	echo "Ciclo = $CICLO"
    numFiles=$(find $NOVEDADES -maxdepth 1 -type f | wc -l )
    echo "Cantidad de archivos encontrados: $numFiles"
    if [ ${numFiles} -gt 0 ]; then
      checkNovedades
    else
      echo "NO HAY NOVEDADES -> llamar a analizar ACEPTADOS"
    fi

    sleep $SLEEP_TIME

    CICLO=$((CICLO + 1))
done
