#!/bin/bash

source ./inicializaciones.sh

CICLO=0
SLEEP_TIME=5
LOG_DAEMON="$LOG/daemon.log"


# cargo estas variables que las necesita para leer un maestro
GRUPO5_MAESTROS=$MAESTROS
GRUPO5_MAESTRO_DE_BANCOS="maestro_de_bancos.csv"
## lista_de_bancos=$(./cargar_maestro_bancos.sh) <-- problemas con el read


# obtengo la lista de bancos 
getArrayBanksName(){
    BANCOS="$MAESTROS/maestro_de_bancos.csv"
    index=0
    
    while read line; do
        lista_de_bancos[$index]=$(echo $line | cut -d";" -f 1)
        echo "Vector lista_de_bancos[$index] = ${lista_de_bancos[$index]}"
        index=`expr $index + 1`
    done <$BANCOS
}



validateNovedad(){

    filename=${entry##*/}
    filename=${filename%.*} 
	echo "filename = $filename"
    
	regex="^[A-Z]{1,19}(_)[0-9]{4}[0-1][0-9][0-3][0-9]$"
	if [[ $filename =~ ^$regex ]]; then
        
		banco=$(./extraer_nombre_de_banco.sh $filename)
        
        echo -e "Lista enviada a validar Banco: ${lista_de_bancos[@]}"
		banco_validado=$(./validar_banco.sh $banco ${lista_de_bancos[@]} )
		fecha=$(./extraer_fecha.sh $filename)
		fecha_validada=$(./validar_fecha.sh $fecha)
		
        echo "la fecha es = $fecha = $fecha_validada"
        echo "Validar Banco = $banco  = $banco_validado"
        
        if [ "$fecha_validada" == "true" ] && [ "$banco_validado" == "true" ]; then 
            ./moverArchivos.sh $entry $ACEPTADOS
        else
            ./moverArchivos.sh $entry $RECHAZADOS
        fi        
    else
        ./moverArchivos.sh $entry $RECHAZADOS
    fi   
    
}




# Verifica si hay novedades en la carpeta de novedades
checkNovedades(){
    local counter=0
    GRUPO5_NOVEDADES=$NOVEDADES
    
    getArrayBanksName
    
    for entry in "$GRUPO5_NOVEDADES"/*
    do
        echo "Archivo $entry"
        validateNovedad
        
        counter=`expr $counter + 1`
    done
    
    
    if [ $counter == 0 ]; then 
        validateAceptados
    fi
}




ciclar() {

    
    ./log.sh -w Loop -m "Ciclo número $CICLO " -i $LOG_DAEMON
    
    checkNovedades
    
    
    sleep $SLEEP_TIME
            
    CICLO=`expr $CICLO + 1`   
    
    # No cicle indefinidamente por ahora 
    if [ $CICLO == 3 ]; then 
        echo "final daemon"
        exit 3
    fi
    #restart 
    ciclar
}



ciclar

