FILENAME="$MAESTROS"/"$GRUPO5_MAESTRO_DE_BANCOS"
#echo "filename de maestro de bancos $FILENAME"
#sumador="( "
while IFS='' read -r line || [[ -n "$line" ]]; do
IFS=';' read -r -a array <<< "$line"
#echo "$line"
sumador="$sumador${array[0]} "
done < "$FILENAME"
echo "$sumador"
