valido="false"
file_bank_code="$1"
array_bancos=$2
#echo "el array recibido es $array_bancos"

#file_bank_code="${file_bank_code##*/}"
file_bank_code="${file_bank_code%_*}"
#echo "$array_bancos"
for bank_code in $array_bancos
do
        echo "$bank_code ? $file_bank_code"
        if [ "$file_bank_code" == "$bank_code" ]
        then
		valido="true"
        fi
done
echo "$valido"
