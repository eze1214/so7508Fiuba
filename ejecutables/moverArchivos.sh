#!/bin/bash

# Movimiento de archivos 

DUPLICADOS="duplicados"

########################################################################
#                             Modo Uso 
#
#
#   ./moverArchivos.sh "ruta_archivo" "ruta_carpeta_destino"  
#
#   Retornos:
#   0:      Copia Correcta
#   1:      Faltan Parámetros 
#   2:      La ruta de origen no es la de un archivo
#   3:      La ruta de destino no es una carpeta 
#   4:      No se pudo crear la carpeta a colocar dupicados
#   5:      Error la realizar la copia, la copia no se realizó 
#
########################################################################



# realizar la copia del archivo 
copy(){
    local destPath=$1
    cp $sourceFilePath $destPath 2> /dev/null 
    
}


# Generar el número de secuencia correspondiente para este duplicado
nextDupFileSeq(){
    # Patron de nombre buscado 
    local pattern="${name}_"
    
    # obtengo los archivos que cumplen con el patron y me quedo con el primero    
    lastDupFilename=$( ls  -r $dupDirPath | awk  -v pattern=$pattern ' $0 ~ pattern {print}' | tr '\n' ',' | cut -d"," -f 1)   
    
    ## No encuentra el patrón buscado
    if [ -z "$lastDupFilename" ]; then 
        return 1
    fi
    
    ## Encuentra el patrón => genera un número más del ultimo encontrado
    # Quitar path nombre hasta "_"
    local nextFilenameSeq=${lastDupFilename##*_}
    # quitar extension a lo que quedá y así obtener número de secuencia 
    nextFilenameSeq=${nextFilenameSeq%.*}   
    
    if [ -z  $nextFilenameSeq ]; then 
        nextFilenameSeq=0
    fi
    
    # Sumar uno al valor encontrado 
    nextFilenameSeq=`expr $nextFilenameSeq + 1`
    
    return $nextFilenameSeq
}


dupFile() {    
    # Genero la carpeta duplicados si no existe
    dupDirPath="$destPath/$DUPLICADOS"
    
    if [ ! -d $dupDirPath ]; then 
        mkdir $dupDirPath
        
        if [ ! -d $dupDirPath ]; then 
            exit 4
        fi
    fi 
    
    nextDupFileSeq
    local sequence=$?
    local newName="$name""_$sequence$extension"
       
    dupFileDestPath=$dupDirPath/$newName 
    copy $dupFileDestPath
}




#  Cuerpo principal 

# Debe haber dos parametros, caso contrarío error
if [ $# -lt 2 ]; then
    echo -e "Error! Faltan parámetros" >&2
    exit 1
fi

sourceFilePath="$1"
destPath="$2"

#sourceFilePath="$NOVEDADES/novedad2.csv"
#destPath="$ACEPTADOS"


# El origen debe ser un archivo 
if [ ! -f $sourceFilePath ]; then 
    echo "Error! La ruta de origen debe ser un archivo" >&2
    exit 2
fi

# El destino debe ser una carpeta
if [ ! -d $destPath ]; then 
    echo "Error! La ruta de destino debe ser un directorio" >&2
    exit 3
fi

# Obtengo el nombre del archivo
filename=$(echo "$sourceFilePath" | sed 's/.*\///')
# Obtengo el nombresin extensión
name=${filename%.*} 
# Ontengo la extensión
extension=${filename##*.} 

if [ "$extension" = "$name" ]; then 
    extension=""
else
    extension=".$extension"
fi
# Armo la ruta de destino del archivo, si no tuviera duplicados
dupFileDestPath=$destPath/$filename 

# si ese archivo ya existe, entonces es un duplicado, sino lo copio
if [ -f $dupFileDestPath ]; then
    dupFile
else
    copy $dupFileDestPath
fi

# si no se realizo la copia => error 5    
if [ ! -f $dupFileDestPath ]; then 
    exit 5
fi
    
exit 0







