valido="false"
file_bank_code=$1
file_bank_code="${file_bank_code##*/}"
file_bank_code="${file_bank_code%_*}"
echo "$file_bank_code"
for bank_code in $(./cargar_maestro_bancos.sh)
do
       	#echo "$bank_code ? $file_bank_code"
        if [ $file_bank_code == "$bank_code" ]
        then
		valido="true"
        fi
done
echo "$valido"
