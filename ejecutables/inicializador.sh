while IFS='' read -r line || [[ -n "$line" ]]; do
IFS='=' read -r -a array <<< "$line"
echo "GRUPO5_${array[0]}=\"${array[1]}\""
#varenv="GRUPO5_${array[0]}"
#echo "$GRUPO5_CONFDIR"
done < "$HOME/grupo05/dirconf/config.cnf"
