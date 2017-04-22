FILENAME="$GRUPO5_MAESTROS"/"$GRUPO5_MAESTRO_DE_BANCOS"
#echo "$FILENAME"
while IFS='' read -r line || [[ -n "$line" ]]; do
IFS=';' read -r -a array <<< "$line"
#echo "$line"
echo "${array[0]}"

done < "$FILENAME"
