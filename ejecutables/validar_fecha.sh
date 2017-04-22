valido="false"
for bank_code in $(./cargar_maestro_bancos.sh)
do
#       echo "$bank_code ? $1"
        if [ "$1" == "$bank_code" ]
        then
                valido="true"
        fi
done
echo "$valido"

