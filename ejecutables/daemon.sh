

lista_de_bancos=$($BINARIOS/cargar_maestro_bancos.sh)
for entry in "$NOVEDADES"/*
do
	filename=${entry##*/}
    filename=${filename%.*} 
	echo "filename = $filename"
	regex="^[A-Z]{1,19}(_)[0-9]{4}[0-1][0-9][0-3][0-9]$"
	if [[ $filename =~ ^$regex ]]
		then
		#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
		echo "pasa el primer validado"
		banco=$($BINARIOS/extraer_nombre_de_banco.sh $filename)
		#echo "el resultado del banco es = $banco" 
	

		banco_validado=$($BINARIOS/validar_banco.sh $banco "${lista_de_bancos[@]}")
		echo "validar banco = $banco_validado"
		if [ "$banco_validado" == "false" ]
			then
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
			echo "no pasa el validador de banco"
		fi
		fecha=$($BINARIOS/extraer_fecha.sh $filename)
		echo "la fecha es = $fecha"
		fecha_validada=$($BINARIOS/validar_fecha.sh $fecha)
		echo "validar fecha = $fecha_validada"
		if [ "$fecha_validada" == "false" ]
			then
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
			echo "no pasa el validador de fecha"
		fi
		if [ "$fecha_validada" == "true" ] && [ "$banco_validado" == "true" ]
			then
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_ACEPTADOS/filename
            echo "ACEPTADOS"
            $BINARIOS/moverArchivos.sh $entry $ACEPTADOS
		else
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
            $BINARIOS/moverArchivos.sh $entry $RECHAZADOS
		echo "ta todo mal 1"
		fi
	else
		#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
            $BINARIOS/moverArchivos.sh $entry $RECHAZADOS
		echo "ta todo mal 2"

	fi
done

