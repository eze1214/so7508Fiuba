#!/bin/bash
# Log definido utilizando estandar W5

optHelp(){
    echo -e "Uso: ./log.sh [-w parrafo_comando_funcion] [-i |-e | -a] [-m descripción_del_mensaje] [ path_archivo_a_escribir]

  -w, -where         Comando, rutina o función donde se produce el evento a registrar
  -i -e -a           Indica el tipo de mensaje -i: Informativo (default)  -e Error -a Alerta
  -m                 Descripción del evento a registrar
  path_archivo       Final indicar el path del log donde realizar el write

 Ejemplo:
            ./log.sh -w Generar_Variable -m \"Variable Inexistente\" -e /tmp/file.log
            ./log.sh -w Generar_Variable -m \"Variable Inexistente\" -e /tmp/file.log
 Retorno:
        0       Fin correcto 
        1       Parámetro inválido" 
}

#echo "$(ps -o comm= $PPID)" 

#echo "$(ps -o user= $PPID)" 

if [ $1 = "-h" ]; then 
    optHelp 
    exit 0
fi

what="INFOR"

while [[ $# -gt 1 ]]
do
    command=$1
    
    case $command in
        -w|-where)
            where="$2"
            shift 2
            ;;
        -i)
            what="INFOR"
            shift 
            ;;
        -a)
            what="ALERT"
            shift 
            ;;
        -e)
            what="ERROR!"
            shift 
            ;;
        -m|-why)
            why="$2"
            shift 2
            ;;
        *)
            echo -e "Parámetro '$1' desconocido .. \n"
            optHelp 
            exit 1
            ;;
    esac
done

when="$(date '+%d/%m/%Y %H:%M:%S')" 
who="$(ps -o user= $PPID)"

if [ ! "$where" ]; then
    where="$(ps -o  fname= $PPID)" 
fi

LOG_FILE="$1"

echo "$when-$who-$where-$what-$why" >> "$LOG_FILE"

exit 0
