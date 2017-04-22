#!/bin/sh

# Movimiento de archivos 


if [ $# -lt 2 ]; then
    echo -e "Error! Faltan parámetros"
    exit 1
fi

sourcePath="$1"
destPath="$2"

#sourcePath="$NOVEDADES/novedad2.csv"
#destPath="$ACEPTADOS"


if [ ! -f $sourcePath ]; then 
    echo "Error! El archivo de origen debe ser un archivo"
    exit 2
fi

if [ ! -d $destPath ]; then 
    echo "Error! El archivo de destino debe ser un directorio"
    exit 3
fi




nextValueDupFile(){
    local dirPathDup="$destPath/duplicados"
    local dupName="$name_"
    lastFilenameDup=$( ls -m -r $dirPathDup | grep "$dupName" | cut -d"," -f 1)
    echo "dupName:  $$( ls -m -r $dirPathDup)"
    echo "lastFilenameDup: $lastFilenameDup"
    
    if [ -z $lastFilenameDup ]; then 
        return 1
    fi
    
    nextNumberFilename=${lastFilenameDup##*_} 
    echo "nextNumberFilename: $nextNumberFilename"
    nextNumberFilename=${nextNumberFilename%.*}   
    echo "nextNumberFilename: $nextNumberFilename"
    nextNumberFilename=`expr $nextNumberFilename + 1`
    
    echo "Nuevo número: $nextNumberFilename"
    
    return $nextNumberFilename
}

nameNewDupFile(){
    nextValueDupFile
    value=$?    
    newName="$name""_$value.$extension"
    
    echo "Nuevo nombre: $newName"
}


copy(){
    local dest=$1
    cp $sourcePath $dest
}


fileDup() {    
    # Genero la carpeta duplicados si no existe
    echo "archivo duplicado "
    local dirPathDup="$destPath/duplicados"
    if [ ! -d $dirPathDup ]; then 
        mkdir $dirPathDup
        echo "Generar carpeta"
    fi 
    
    nameNewDupFile    
    local destFileNamePath=$dirPathDup/$newName 
    copy $destFileNamePath
}

fileNoDup(){
#    local newNameDest="$name""_1.$extension"
 #   local destFileNamePath=$destPath/$newFilenameDest 
 echo " Archivo No duplicado "
    copy $destFileNamePath
}


fileName=$(echo "$sourcePath" | sed 's/.*\///')
destFileNamePath=$destPath/$fileName 
name=${fileName%.*} 
extension=${fileName##*.} 

if [ -f $destFileNamePath ]; then
    echo "El archivo existe |$destFileNamePath|"
    fileDup
else
    echo "El archivo NO Existe |$destFileNamePath|"
    fileNoDup
fi







