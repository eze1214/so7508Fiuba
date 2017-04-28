#!/bin/bash
#Uso buscar_banco -c, -n BANCOS (CODIGO o NOMBRE)

#Devuelve el nombre del banco o falso en el caso de no encontrarlo
buscarPorCodigo(){
	encontrado=$(grep ";$CODIGO;" $MAESTRO)
	if [ -z "$encontrado" ]; then
		echo "false"
	else
	echo $( echo $encontrado | cut -d ";" -f 1)
	fi
}

#Devuelve el codigo del banco o falso en el caso de no encontrarlo
buscarPorNombre(){
	encontrado=$(grep "^$NOMBRE" $MAESTRO)
	if [ -z "$encontrado" ]; then
		echo "false"
	else
		echo $(echo $encontrado | cut -d ";" -f 2)
	fi

}

MAESTRO=$2;
if [ $1 = '-c' ]; then 
	CODIGO=$3
	buscarPorCodigo "$2"
elif [ $1 = '-n' ]; then
	NOMBRE=$3
	buscarPorNombre "$2" 
fi 