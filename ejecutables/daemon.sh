for entry in "$GRUPO5_NOVEDADES"/*
do
	filename=${entry##*/}
	echo "filename = $filename"
	parseado=$(./parsear_nombre_de_archivo.sh $filename)
	#echo "el resultado del parseador es = $parseado" 
	validado=$(./validar_banco.sh $parseado)
	#echo "$validado"
		if [ "$validado" == "true" ] 
		then
			echo "true"	


		else	
			echo "false"
	fi
done
