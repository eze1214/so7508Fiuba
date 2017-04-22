IFS='_' read -r -a array <<< "$1"
variable=$1
echo "${variable%_*}"
echo "${variable#*_}"

#echo "${array[0]}"
