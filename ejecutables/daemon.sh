lista_de_bancos=$(./cargar_maestro_bancos.sh)
for entry in "$GRUPO5_NOVEDADES"/*
do
	filename=${entry##*/}
	echo "filename = $filename"
	regex="^[A-Z]{1,19}(_)[0-9]{4}[0-1][0-9][0-3][0-9]$"
	if [[ $filename =~ $regex ]]
		then
		#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
		#echo "pasa el primer validado"
		banco=$(./extraer_nombre_de_banco.sh $filename)
		#echo "el resultado del banco es = $banco" 
	

		banco_validado=$(./validar_banco.sh $banco "${lista_de_bancos[@]}")
		#echo "validar banco = $validado"
		#if [ "$banco_validado" == "false" ]
			#then
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
			#echo "no pasa el validador de banco"
		#fi
		fecha=$(./extraer_fecha.sh $filename)
		#echo "la fecha es = $fecha"
		fecha_validada=$(./validar_fecha.sh $fecha)
		#echo "validar fecha = $validado"
		#if [ "$fecha_validada" == "false" ]
			#then
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
			#echo "no pasa el validador de fecha"
		#fi
		if [ "$fecha_validada" == "true" ] && [ "$banco_validado" == "true" ]
			then
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_ACEPTADOS/filename
			echo "ta todo bien"
		else
			#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
			echo "ta todo mal"
		fi
	else
		#mv $GRUPO5_NOVEDADES/filename GRUPO5_RECHAZADOS/filename
		echo "ta todo mal"

	fi
done
