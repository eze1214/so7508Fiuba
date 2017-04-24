#!/bin/bash/


mastersPer(){
    # Establezco permisos de lectura a los Maestros
    files=$( ls -1 $MAESTROS/ )
    
    if [ ${#files} -eq 0 ]; then 
        echo -e "No Existen archivos maestros"
        exit 1
    fi
    

    for file in $files; do
        chmod 440 $MAESTROS/$file
    done

}


binaryPer(){
    # Permisos de Ejecución para los vinarios
    files=$( ls -1 $BINARIOS/ )

    for file in $files; do
        chmod 110 $BINARIOS/$file
    done
            
    if [ ${#files} -eq 0 ]; then 
        echo -e "No Existen archivos binarios"
        exit 2
    fi
}




mastersPer
binaryPer




