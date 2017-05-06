#!/bin/bash

GRABITAC="$BINDIR/GrabarBitacora.sh"
MOVER="$BINDIR/MoverArchivo.sh"

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
      exit 1
    else
      echo "Ambiente iniciado"
    fi
}

verificarCantidadRegistros(){
  #leo el encabezado 
  local cantidadRegistrosHEAD=$(head -1 $NOVEDADES/$archivo | cut -d ";" -f 1)
  local cantidadRegistros=$(wc -l $NOVEDADES/$archivo | cut -d " " -f 1)
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
  local sumaHEAD=$(head -1 $NOVEDADES/$archivo | cut -d ";" -f 2)
  contenido=$(sed '1d' $NOVEDADES/$archivo | cut -d ";" -f 2)
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
    else
     echo "fecha invalida" >/dev/null
     VALIDO="false"
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
  elif [[ $MONTO_MAYOR_CERO -eq 0 && "$ESTADO" = "Pendiente" ]]; then
    echo "Menor que 0 y pendiente" >/dev/null
    VALIDO="false"
  elif [[ $MONTO_MAYOR_CERO -eq 1 && "$ESTADO" = "Anulada" ]]; then
    echo "mayor que 0 y anulada" >/dev/null
    VALIDO="false"
  else
    VALIDO="false"
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
  else
    echo "el CBU_NOVEDADES no tiene 22 digitos" >/dev/null
    VALIDO="false"
  fi

  if [ $LENGTH_CAMPO5 -eq $LENGTH ]; then
    echo "el CBU_DESTINO tiene 22 digitos" >/dev/null
  else
    echo "el CBU_DESTINO no tiene 22 digitos" >/dev/null
    VALIDO="false"
  fi

  if [ "$CBU_NOVEDADES" = "$CBU_DESTINO" ]; then
    echo "Son iguales CBU_NOVEDADES y CBU_DESTINO" >/dev/null
    VALIDO="false"
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
  else
    echo "Origen no validado" >/dev/null
    VALIDO="false"
  fi
  if [ "$DESTINO_BUSCADO" != "false" ];then
    echo "Destino validado" >/dev/null
  else 
    echo "Destino no validado" >/dev/null
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
  TOTAL_MONTO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*$)/\2/" | sed "s/;//g" ) 
}

generarSalida(){
  HEADER="false"
  while read -r REGISTRO; do
    if [ $HEADER = "false" ]; then
      HEADER="true"
    else
      parsear
      if [ -d $REPORTESDIR/transfer ]; then 
        echo "existe"
      else
        echo "no existe"
        mkdir $REPORTESDIR/transfer
      fi
      COD_CBU_ORIGEN=$(echo $CBU_NOVEDADES | sed "s/\(.\{3\}\)\(.*\)/\1/")
      COD_CBU_DESTINO=$(echo $CBU_DESTINO | sed "s/\(.\{3\}\)\(.*\)/\1/")
      ORIGEN_BUSCADO=$($BINARIOS/buscar_banco.sh -c $MAESTROS/$MAESTRO_DE_BANCOS $COD_CBU_ORIGEN)
      DESTINO_BUSCADO=$($BINARIOS/buscar_banco.sh -c $MAESTROS/$MAESTRO_DE_BANCOS $COD_CBU_DESTINO)
    
      registroGuardar=$(echo "$archivo;$ORIGEN_BUSCADO;$COD_CBU_ORIGEN;$DESTINO_BUSCADO;$COD_CBU_DESTINO;$FECHA;$MONTO;$ESTADO;$COD_CBU_ORIGEN;$COD_CBU_DESTINO")
      echo "guardado $registroGuardar"
      if [ -f "$REPORTESDIR/transfer/$FECHA.txt" ];then
        touch $REPORTESDIR/transfer/$FECHA.txt
      fi
      echo "$registroGuardar" >>$REPORTESDIR/transfer/$FECHA.txt
    fi
  done <"$NOVEDADES/$archivo"
}
verificarAmbiente
  archivo=$1
  echo -------------------------------------------
  VALIDO="true"
  HEADER="false"
  SUMA=0
  CONTADOR=0
  
  while read REGISTRO; do
    if [ $HEADER = "false" ]; then 
      parsearHeader
      echo "header: $TOTAL_REGISTROS, $TOTAL_MONTO"
      #Ya que el header la posicion de estos campos se encuentra en la misma que 
      #la fecha y el monto
      HEADER_CANTIDAD_REGISTROS=$FECHA
      HEADER_MONTO_TOTAL=$MONTO
      HEADER="true"
    else
      #echo "Registro $REGISTRO"
      parsear
      echo $FECHA,$MONTO,$ESTADO,$CBU_NOVEDADES,$CBU_DESTINO
      SUMA=$(echo "$MONTO + $SUMA" | bc)
      let CONTADOR=$CONTADOR+1
      verificarFormato
    fi
    
  done <"$NOVEDADES/$archivo"
  echo "el monto sumados es $SUMA"
  echo "la cantidad de registros sumados $CONTADOR"
  if [ "$SUMA" != "TOTAL_MONTO" ]; then
    VALIDO="false"
  fi
  if [ "$CONTADOR" != "$TOTAL_REGISTROS" ]; then
    VALIDO="false"
  fi
  if [ $VALIDO="true" ]; then
      echo "archivo Valido"
      generarSalida
      if [ -d $VALIDADOSDIR/proc ]; then 
        echo "copiando"
      else
        mkdir $VALIDADOSDIR/proc
      fi
      $($BINARIOS/moverArchivos.sh $NOVEDADES/$archivo $VALIDADOSDIR/proc)
    else
     echo "archivo no valido"
    fi