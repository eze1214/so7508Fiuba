valido="false"
regex="^[0-9]{4}[0-1][0-9][0-3][0-9]"
#echo "entrada = $1"
if [[ $1 =~ $regex  ]]
	then
	date "+%Y%mm%dd" -d "$1" > /dev/null 2>&1	
	is_valid=$?
	#echo "is_valid = $is_valid"
	date_argumento=$1
	date_argumento="$(date +%s -d $date_argumento)"
	#echo "date1 = $date_argumento"
	#date2="$(date +%Y%m%d --date=\"now - 15 days\")"
	date2=`date --date="15 days ago" +%Y%m%d`
	date_15_dias="$(date +%s -d $date2)"
	date_hoy=`date --date="now" +%Y%m%d`
	date_hoy="$(date +%s -d $date_hoy)"

	if [ $is_valid == 0 ] && [ $date_15_dias -lt $date_argumento ] && [ $date_argumento -lt $date_hoy ]
		then
		valido="true"
	fi
fi
echo "$valido"
