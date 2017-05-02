#!/bin/bash

GRABITAC="$BINDIR/GrabarBitacora.sh"
MOVER="$BINDIR/MoverArchivo.sh"
NOVEDADES=/home/ezequiel/grupo05/novedades/
EJECUTABLES=/home/ezequiel/sisop/

ambienteInicializado{
  if [ "${GRUPO}" == "" ]; then 
    return 1
  fi

  if [ "${BINARIOS}" == "" ]; then  
    return 1
  fi

  if [ "${MAESTROS}" == "" ]; then  
    return 1
  fi

  if [ "${NOVEDADES}" == "" ]; then 
    return 1
  fi

  if [ "${ACEPTADOS}" == "" ]; then 
    return 1
  fi

  if [ "${RECHAZADOS}" == "" ]; then  
    return 1
  fi

  if [ "${VALIDADOSDIR}" == "" ]; then  
    return 1
  fi

  if [ "${REPORTESDIR}" == "" ]; then 
    return 1
  fi

  if [ "${LOG}" == "" ]; then 
    return 1
  fi

  if [ "${MAESTRO_DE_BANCOS}" == "" ]; then 
    return 1
  fi
  return 0
}

function verificarAmbiente(){
    ambienteInicializado 
    if [ $? == 1 ]; then
      local mensajeError="Ambiente no inicializado"
      echo "$Ambiente no inicializado"
      exit 1
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
  echo "total: $suma"
  result=$(printf "%0.2f\n" $suma)
  echo "result $result"
  echo "total: $sumaHEAD"
  if [ "$sumaHEAD" == "$suma" ]; then
    echo "$archivo pasa la prueba del monto"
  else
    VALIDO="false"
      echo "$archivos no pasa la prueba del monto"
  fi
}


verificarFechas(){
    echo "Fecha procesada $FECHA, fecha extraida $(./extraer_fecha.sh $archivo)"
    verificacionFecha=$(./validar_fecha2.sh $FECHA $(./extraer_fecha.sh $archivo))
    if [ "$verificacionFecha" = "true" ]; then 
      echo "fecha correcta"
    else
     echo "fecha invalida"
     VALIDO="false"
    fi
}

verificarCampos23(){
  MONTO=$(echo $MONTO | bc)
  MONTO_MAYOR_CERO=$(echo "$MONTO > 0" | bc)
      echo "estado : $ESTADO"
    echo "monto : $MONTO"
    echo "Condicion $MONTO_MAYOR_CERO"
  if [[ $MONTO_MAYOR_CERO -eq 1 && "$ESTADO" = "Pendiente" ]]; then
    echo "Mayor que 0 y pendiente"
  elif [[ $MONTO_MAYOR_CERO -eq 0 && "$ESTADO" = "Anulada" ]]; then
    echo "Menor que 0 y anulada"
  elif [[ "$ESTADO" != "Anulada" && "$ESTADO" != "Pendiente" ]];then
    echo "Campo 3 es diferente de anulada o pendiente"
  elif [[ $MONTO_MAYOR_CERO -eq 0 && "$ESTADO" = "Pendiente" ]]; then
    echo "Menor que 0 y pendiente"
  elif [[ $MONTO_MAYOR_CERO -eq 1 && "$ESTADO" = "Anulada" ]]; then
    echo "mayor que 0 y anulada"
  else
    echo "Ningun otro caso"
    echo "estado : $ESTADO"
    echo "monto : $MONTO"
    echo "Condicion $MONTO_MAYOR_CERO"
  fi
}

verificarCampos45(){
  LENGTH=22

  #CBU_NOVEDADES=$(echo registro)
  LENGTH_CAMPO4=${#CBU_NOVEDADES}
  LENGTH_CAMPO5=${#CBU_DESTINO}
  echo "NOVEDADES $CBU_NOVEDADES, destino $CBU_DESTINO,"
  
  echo "length $LENGTH_CAMPO4 length $LENGTH_CAMPO5"
  if [ $LENGTH_CAMPO4 -eq $LENGTH ]; then 
    echo "el CBU_NOVEDADES tiene 22 digitos"
  else
    echo "el CBU_NOVEDADES no tiene 22 digitos"
  fi

  if [ $LENGTH_CAMPO5 -eq $LENGTH ]; then
    echo "el CBU_DESTINO tiene 22 digitos"
  else
    echo "el CBU_DESTINO no tiene 22 digitos"
  fi

  if [ "$CBU_NOVEDADES" = "$CBU_DESTINO" ]; then
    echo "Son iguales CBU_NOVEDADES y CBU_DESTINO"
  else 
    echo "no son iguales CBU_NOVEDADES y CBU_DESTINO"
  fi
}

verificarBancos(){
  COD_CBU_NOVEDADES=$(echo $CBU_NOVEDADES | sed "s/\(.\{3\}\)\(.*\)/\1/")
  COD_CBU_DESTINO=$(echo $CBU_DESTINO | sed "s/\(.\{3\}\)\(.*\)/\1/")
  echo "COD_CBU_NOVEDADES $COD_CBU_NOVEDADES, COD_CBU_DESTINO $COD_CBU_DESTINO"
  NOVEDADES_BUSCADO=$(.$NOVEDADES/buscar_banco.sh -c /bamae.csv $COD_CBU_NOVEDADES)
  DESTINO_BUSCADO=$(.$NOVEDADES/buscar_banco.sh -c ./bamae.csv $COD_CBU_DESTINO)
  if [ "$NOVEDADES_BUSCADO" != "false" ]; then
    echo "NOVEDADES validado"
  else
    echo "NOVEDADES no validado"
  fi
  if [ "$DESTINO_BUSCADO" != "false" ];then
    echo "Destino validado"
  else 
    echo "Destino no validado"
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
  MONTO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\2/" | sed "s/;//g" ) 
  ESTADO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\3/" | sed "s/;//g" )
  CBU_NOVEDADES=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)(.*$)/\4/" | sed "s/;//g" )
  CBU_DESTINO=$(echo "$REGISTRO"| sed -r "s/(.*;)(.*;)(.*;)(.*;)([0-9]*)(.*$)/\5/" | sed "s/;//g" )
}
#verificarAmbiente
echo "hola"
#Ordeno los archivos cronologicamente (mas antiguo al mas reciente) y los proceso
archivosOrdenados=$(ls -A "$NOVEDADES" | sed 's-^\(.*\)\([0-9]\{8\}\)\.csv$-\2\1.csv-g' | sort | sed 's-^\([0-9]\{8\}\)\(.*\)\.csv$-\2\1.csv-g')
for archivo in $archivosOrdenados ; do
  echo $archivo
  echo $NOVEDADES
  echo -------------------------------------------
  #echo $registro
  #verificarCantidadRegistros
  #verificarMonto
  #
  VALIDO="true"
  HEADER="false"
  SUMA=0
  CONTADOR=0
  
  while read -r REGISTRO; do
    echo "Registro $REGISTRO"
    
    parsear

    if [ $HEADER = "false" ]; then 
      echo "header: $FECHA, $MONTO"
      #Ya que el header la posicion de estos campos se encuentra en la misma que 
      #la fecha y el monto
      HEADER_CANTIDAD_REGISTROS=$FECHA
      HEADER_MONTO_TOTAL=$MONTO
      HEADER="true"
    else
      echo $FECHA,$MONTO,$ESTADO,$CBU_NOVEDADES,$CBU_DESTINO
      SUMA=$(echo "$MONTO + $SUMA" | bc)
      let CONTADOR=$CONTADOR+1
      verificarFormato
    fi
    if [ $VALIDO="true" ]; then
      echo "archivo Valido"
    else
     echo "archivo no valido"
    fi
  done <"$NOVEDADES$archivo"
  echo "el monto sumado es $SUMA"
  echo "la contidad de registros sumados $CONTADOR"
done
