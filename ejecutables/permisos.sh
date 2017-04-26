
mastersPermisos(){
    # Establezco permisos de lectura a los Maestros
    files=$( ls -1 $MAESTROS/ )
    
    if [ ${#files} -eq 0 ]; then 
        echo -e ".... Error! No Existen archivos maestros"
        exit 1
    fi
    

    for file in $files; do
        chmod 777 $MAESTROS/$file
    done

}


binaryPermisos(){
    # Permisos de Ejecución para los vinarios
    files=$( ls -1 $BINARIOS/ )

    for file in $files; do
        chmod 777 $BINARIOS/$file
    done
            
    if [ ${#files} -eq 0 ]; then 
        echo -e ".... Error! No Existen archivos binarios"
        exit 2
    fi
}



# Estableciendo permisos a archivos maestros 
mastersPermisos

# Estableciendo permisos binarios
binaryPermisos




