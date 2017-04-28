#!/bin/bash
#Valida la fecha según los requerimientos del comando validador
#date_argumento fecha ingresada en un registros
#date_filename fecha del filename
#valida_fecha2 date_argumento date_filaname

valido="false"
regex="^[0-9]{4}[0-1][0-9][0-3][0-9]"
date_argumento=$1
date_filename=$2
#echo "entrada = $1"
if [[ $date_argumento =~ $regex ]];then 
	if [[ "$date_filename" =~ $regex ]]; then
		date "+%Y%mm%dd" -d "$1" > /dev/null 2>&1	
		is_valid_argumento=$?
		date "+%Y%mm%dd" -d "$2" > /dev/null 2>&1
		is_valid_filename=$?

		nextWeek=$(date --date="$date_filename +7 days" +%Y%m%d )
		date_argumento=$(date +%s -d $date_argumento)
		date_filename=$(date +%s -d $date_filename)
		date_next_week=$(date +%s -d $nextWeek)
		
		if [ $is_valid_argumento -eq 0 ] && [ $is_valid_filename -eq 0 ] && [ $date_argumento -ge $date_filename ] && [ $date_argumento -le $date_next_week ];then
			valido="true"
		fi
	fi
fi
echo "$valido"