valido="false"
#regex="^[0-9]{4}[0-1][0-9][0-3][0-9]"
#echo "entrada = $1"
if [[ $1 =~ $regex  ]]
	then
	date "+%Y%mm%dd" -d "$1" > /dev/null 2>&1	
	is_valid=$?
	#echo "is_valid = $is_valid"

	#if [ $is_valid == 0 ] && [ date -d "now - 15 days" -lt date -d "$1" ] && [ date -d "$1" -lt date -d "now" ]
	if [ $is_valid == 0 ]
		then
		valido="true"
	fi
fi
echo "$valido"
