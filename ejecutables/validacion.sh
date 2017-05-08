#!/bin/bash

MOVER="$BINDIR/MoverArchivo.sh"
ORIGEN="$ACEPTADOS"
LOG_VALIDADOR="$LOG/validador.log"

ambienteInicializado(){
  if [ "${GRUPO}" = "" ]; then 
    echo 1
  elif [ "${BINARIOS}" = "" ]; then  
    echo 1
  elif [ "${MAESTROS}" = "" ]; then  
    echo 1
  elif [ "${NOVEDADES}" = "" ]; then 
    echo 1
  elif [ "${ACEPTADOS}" = "" ]; then 
    echo 1
  elif [ "${RECHAZADOS}" = "" ]; then  
    echo 1
  elif [ "${VALIDADOSDIR}" = "" ]; then  
    echo 1
  elif [ "${REPORTESDIR}" = "" ]; then 
    echo 1
  elif [ "${LOG}" = "" ]; then 
    echo 1
  elif [ "${MAESTRO_DE_BANCOS}" = "" ]; then 
    echo 1
  else
  echo 0
fi
}

function verificarAmbiente(){
    result=$(ambienteInicializado) 
    echo " result $result"
    if [ "$result" = 1 ]; then
      echo "Error ambiente no inicializado"
      $BINARIOS/log.sh -w "VALIDADOR"  -m "El ambiente no fue inicializado" -e $LOG_VALIDADOR
      exit 1
    else
      echo "Ambiente iniciado"
      $BINARIOS/log.sh -w "VALIDADOR"  -m "Se cargaron satisfactoriamente las variables del ambiente" -i $LOG_VALIDADOR
    fi
}

verificarCantidadRegistros(){
  #leo el encabezado 
  local cantidadRegistrosHEAD=$(head -1 $ORIGEN/$archivo | cut -d ";" -f 1)
  local cantidadRegistros=$(wc -l $ORIGEN/$archivo | cut -d " " -f 1)
  let cantidadRegistros=cantidadRegistros-1 
  echo "$cantidadRegistrosHEAD - - $cantidadRegistros"
  if [ $cantidadRegistrosHEAD = $cantidadRegistros ]; then
  echo -e "\n$archivo pasa la prueba de la cantidad de registros"
  else
  VALIDO="false"
  echo -e "\n$archivo no pasa la prueba de la cantidad de reigstos"
  fi    
}

verificarMonto(){
  #Le borro el encabezado
  local suma=0
  local sumaHEAD=$(head -1 $ORIGEN/$archivo | cut -d ";" -f 2)
  contenido=$(sed '1d' $ORIGEN/$archivo | cut -d ";" -f 2)
  echo -e "\n$contenido"
  for linea in $contenido; do
    echo $linea
    let suma=$suma+$linea
    #suma=$(printf "%0.2f\n" $suma)  
    echo -e "\nsuma: $suma"
  done
  #echo "total: $suma"
  result=$(printf "%0.2f\n" $suma)
  #echo "result $result"
  #echo "total: $sumaHEAD"
  if [ "$sumaHEAD" == "$suma" ]; then
    echo "$archivo pasa la prueba del monto"
  else
    VALIDO="false"
      #echo "$archivos no pasa la prueba del monto"
  fi
}


verificarFechas(){
    #echo "Fecha procesada $FECHA, fecha extraida $($BINARIOS/extraer_fecha.sh $archivo)"
    verificacionFecha=$($BINARIOS/validar_fecha2.sh $FECHA $($BINARIOS/extraer_fecha.sh $archivo))
    if [ "$verificacionFecha" = "true" ]; then 
      echo "fecha correcta" >/dev/null
      $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR Fecha Validada" -i $LOG_VALIDADOR
    else
     echo "fecha invalida" >/dev/null
     VALIDO="false"
     $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR Fecha Invalida" -e $LOG_VALIDADOR
    fi
}

verificarCampos23(){
  MONTO=$(echo $MONTO | bc)
  MONTO_MAYOR_CERO=$(echo "$MONTO > 0" | bc)
      #echo "estado : $ESTADO"
    #echo "monto : $MONTO"
    #echo "Condicion $MONTO_MAYOR_CERO"
  if [[ $MONTO_MAYOR_CERO -eq 1 && "$ESTADO" = "Pendiente" ]]; then
    echo "Mayor que 0 y pendiente" >/dev/null
  elif [[ $MONTO_MAYOR_CERO -eq 0 && "$ESTADO" = "Anulada" ]]; then
    echo "Menor que 0 y anulada" >/dev/null
  elif [[ "$ESTADO" != "Anulada" && "$ESTADO" != "Pendiente" ]];then
    echo "Campo 3 es diferente de anulada o pendiente" >/dev/null
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR El campo 3 es diferente de Anulada o Pendiente" -e $LOG_VALIDADOR
  elif [[ $MONTO_MAYOR_CERO -eq 0 && "$ESTADO" = "Pendiente" ]]; then
    echo "Menor que 0 y pendiente" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR Tiene Monto menor a 0 y estado pendiente" -e $LOG_VALIDADOR
    VALIDO="false"
  elif [[ $MONTO_MAYOR_CERO -eq 1 && "$ESTADO" = "Anulada" ]]; then
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR Tiene monto mayor a 0 y estodo Anulada" -e $LOG_VALIDADOR
    echo "mayor que 0 y anulada" >/dev/null
    VALIDO="false"
  else
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $Contador Tiene un estado invalido" -e $LOG_VALIDADOR
    #echo "Ningun otro caso"
    #echo "estado : $ESTADO"
    #echo "monto : $MONTO"
    #echo "Condicion $MONTO_MAYOR_CERO"
  fi
}

verificarCampos45(){
  LENGTH=22

  #CBU_NOVEDADES=$(echo registro)
  LENGTH_CAMPO4=${#CBU_NOVEDADES}
  LENGTH_CAMPO5=${#CBU_DESTINO}
  #echo "NOVEDADES $CBU_NOVEDADES, destino $CBU_DESTINO,"
  
  #echo "length $LENGTH_CAMPO4 length $LENGTH_CAMPO5"
  if [ $LENGTH_CAMPO4 -eq $LENGTH ]; then 
    echo "el CBU_NOVEDADES tiene 22 digitos" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR validado el CBU Origen" -i $LOG_VALIDADOR
  else
    echo "el CBU_NOVEDADES no tiene 22 digitos" >/dev/null
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR el CBU origen es invalido no tiene 22 digitos" -e $LOG_VALIDADOR
  fi

  if [ $LENGTH_CAMPO5 -eq $LENGTH ]; then
    echo "el CBU_DESTINO tiene 22 digitos" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR validado el CBU Destino" -i $LOG_VALIDADOR
  else
    echo "el CBU_DESTINO no tiene 22 digitos" >/dev/null
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR el CBU destino es invalido no tiene 22 digitos" -e $LOG_VALIDADOR
  fi

  if [ "$CBU_NOVEDADES" = "$CBU_DESTINO" ]; then
    echo "Son iguales CBU_NOVEDADES y CBU_DESTINO" >/dev/null
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR el CBC origen y destino son iguales" -e $LOG_VALIDADOR
  else 
    echo "no son iguales CBU_NOVEDADES y CBU_DESTINO" >/dev/null
  fi
}

verificarBancos(){
  COD_CBU_ORIGEN=$(echo $CBU_NOVEDADES | sed "s/\(.\{3\}\)\(.*\)/\1/")
  COD_CBU_DESTINO=$(echo $CBU_DESTINO | sed "s/\(.\{3\}\)\(.*\)/\1/")
  echo "COD_CBU_ORIGEN $COD_CBU_ORIGEN, COD_CBU_DESTINO $COD_CBU_DESTINO" >/dev/null
  ORIGEN_BUSCADO=$($BINARIOS/buscar_banco.sh -c $MAESTROS/$MAESTRO_DE_BANCOS $COD_CBU_ORIGEN)
  DESTINO_BUSCADO=$($BINARIOS/buscar_banco.sh -c $MAESTROS/$MAESTRO_DE_BANCOS $COD_CBU_DESTINO)
  echo "$ORIGEN_BUSCADO $DESTINO_BUSCADO" >/dev/null
  if [ "$ORIGEN_BUSCADO" != "false" ]; then
    echo "Origen validado" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR CBU origen válido" -i $LOG_VALIDADOR
  else
    echo "Origen no validado" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR CBU origen invalido no existe en el archivo maestro" -e $LOG_VALIDADOR
    VALIDO="false"
  fi
  if [ "$DESTINO_BUSCADO" != "false" ];then
    echo "Destino validado" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR CBU origen válido" -i $LOG_VALIDADOR
  else 
    echo "Destino no validado" >/dev/null
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Registro: $CONTADOR CBU destino inválido no existe en el archivo maestro" -e $LOG_VALIDADOR
    VALIDO="false"
  fi
}

verificarFormato(){
  verificarFechas 
  verificarCampos23
  verificarCampos45
  verificarBancos
}

parsear(){
  FECHA=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\1/" | sed "s/;//g" )
  MONTO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\2/" | sed "s/;//g" | sed "s/,/\./" ) 
  ESTADO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\3/" | sed "s/;//g" )
  CBU_NOVEDADES=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\4/" | sed "s/;//g" )
  CBU_DESTINO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)([0-9]*)(.*$)/\5/" | sed "s/;//g" )
}

parsearHeader(){
  TOTAL_REGISTROS=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*$)/\1/" | sed "s/;//g" )
  TOTAL_MONTO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*$)/\2/" | sed "s/;//g" | sed "s/,/\./" |  sed  -r "s/(.+\.)(..)(.*)/\1\2/" | bc) 
}

verificarExistenciaArchivo(){
  if [ -f $VALIDADOSDIR/proc/$archivo ]; then 
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Archivo $archivo: Ya fue procesado, enviado al directorio de rechazados " -e $LOG_VALIDADOR
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Fin de validador " -i $LOG_VALIDADOR
    $($BINARIOS/moverArchivos.sh $ORIGEN/$archivo $RECHAZADOS)
  fi
  exit 1
}

generarSalida(){
  HEADER="false"
  while read -r REGISTRO; do
    if [ $HEADER = "false" ]; then
      HEADER="true"
    else
      parsear
      if [ -d $REPORTESDIR/transfer ]; then 
        echo "existe" >/dev/null
      else
        #echo "no existe"
        $BINARIOS/log.sh -w "VALIDADOR"  -m "Generado directorio tranfer" -i $LOG_VALIDADOR
        mkdir $REPORTESDIR/transfer
      fi
      COD_CBU_ORIGEN=$(echo $CBU_NOVEDADES | sed "s/\(.\{3\}\)\(.*\)/\1/")
      COD_CBU_DESTINO=$(echo $CBU_DESTINO | sed "s/\(.\{3\}\)\(.*\)/\1/")
      ORIGEN_BUSCADO=$($BINARIOS/buscar_banco.sh -c $MAESTROS/$MAESTRO_DE_BANCOS $COD_CBU_ORIGEN)
      DESTINO_BUSCADO=$($BINARIOS/buscar_banco.sh -c $MAESTROS/$MAESTRO_DE_BANCOS $COD_CBU_DESTINO)
    
      registroGuardar=$(echo "$archivo;$ORIGEN_BUSCADO;$COD_CBU_ORIGEN;$DESTINO_BUSCADO;$COD_CBU_DESTINO;$FECHA;$MONTO;$ESTADO;$COD_CBU_ORIGEN;$COD_CBU_DESTINO")
      echo "guardado $registroGuardar" >/dev/null
      if [ -f "$REPORTESDIR/transfer/$FECHA.txt" ];then
        touch $REPORTESDIR/transfer/$FECHA.txt
      fi
      echo "$registroGuardar" >>$REPORTESDIR/transfer/$FECHA.txt
      $BINARIOS/log.sh -w "VALIDADOR"  -m "Guardado registro en $REPORTESDIR/transfer/$FECHA.txt" -i $LOG_VALIDADOR
    fi
  done <"$ORIGEN/$archivo"
  $BINARIOS/log.sh -w "VALIDADOR"  -m "Se generaron todos los reportes para $archivo" -i $LOG_VALIDADOR
}
  archivo=$1
  verificarAmbiente
  verificarExistenciaArchivo

  echo -------------------------------------------
  VALIDO="true"
  HEADER="false"
  SUMA=0
  CONTADOR=0
  $BINARIOS/log.sh -w "VALIDADOR"  -m "Archivo Leido: $archivo" -i $LOG_VALIDADOR

  while read REGISTRO; do
    if [ $HEADER = "false" ]; then 
      parsearHeader
      echo "header: $TOTAL_REGISTROS, $TOTAL_MONTO"
      #Ya que el header la posicion de estos campos se encuentra en la misma que 
      #la fecha y el monto
      HEADER_CANTIDAD_REGISTROS=$TOTAL_REGISTROS
      HEADER_MONTO_TOTAL=$TOTAL_MONTO
      HEADER="true"
    else
      #echo "Registro $REGISTRO"
      parsear
      echo $FECHA,$MONTO,$ESTADO,$CBU_NOVEDADES,$CBU_DESTINO
      SUMA=$(echo "$MONTO + $SUMA" | bc)
      let CONTADOR=$CONTADOR+1
      verificarFormato
    fi
    
  done <"$ORIGEN/$archivo"
  echo "el monto sumados es $SUMA" >/dev/null
  echo "la cantidad de registros sumados $CONTADOR" >/dev/null
  if [ $SUMA != $TOTAL_MONTO ]; then
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Error en hash total. Sumatoria: $SUMA. Monto informado: $HEADER_MONTO_TOTAL." -e $LOG_VALIDADOR
  fi
  if [ "$CONTADOR" != "$TOTAL_REGISTROS" ]; then
    VALIDO="false"
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Error en cantidad de registros. Contados: $CONTADOR Cantidad informada: $HEADER_CANTIDAD_REGISTROS. " -e $LOG_VALIDADOR
  fi
  if [ $VALIDO = "true" ]; then
      echo "archivo Valido"
      $BINARIOS/log.sh -w "VALIDADOR"  -m "Archivo $Archivo es valido" -i $LOG_VALIDADOR
      generarSalida
      if [ -d $VALIDADOSDIR/proc ]; then 
        echo "copiando"
      else
        mkdir $VALIDADOSDIR/proc
      fi
      $($BINARIOS/moverArchivos.sh $ORIGEN/$archivo $VALIDADOSDIR/proc)
    else
     echo "archivo no valido"
     $BINARIOS/log.sh -w "VALIDADOR"  -m "Archivo $Archivo no valido se mueve al directorio de rechazados" -e $LOG_VALIDADOR
    fi
    $BINARIOS/log.sh -w "VALIDADOR"  -m "Fin de VALIDADOR" -i $LOG_VALIDADOR