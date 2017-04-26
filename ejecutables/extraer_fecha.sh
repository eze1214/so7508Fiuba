filename=$1
filename="${filename#*_}"

echo "${filename%.*}"
