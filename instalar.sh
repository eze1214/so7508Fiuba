	#!/bin/bash

GRUPO=~/grupo05
CONFG="$GRUPO/dirconf/config.cnf"
ARCH_LOG="log.txt"

escribirConfig () {
	WHEN=`date +%d/%m/%Y-%T`
	WHO=${USER}	

	echo "GRUPO=$GRUPO=$WHO=$WHEN" >> "$CONFG"
	echo "BINARIOS=$GRUPO/$EJECUTABLES=$WHO=$WHEN" >> "$CONFG"
	echo "MAESTROS=$GRUPO/$MAESTROS=$WHO=$WHEN" >> "$CONFG"
	echo "NOVEDADES=$GRUPO/$NOVEDADES=$WHO=$WHEN" >> "$CONFG"
	echo "ACEPTADOS=$GRUPO/$ACEPTADOS=$WHO=$WHEN" >> "$CONFG"
	echo "RECHAZADOS=$GRUPO/$RECHAZADOS=$WHO=$WHEN" >> "$CONFG"
	echo "VALIDADOSDIR=$GRUPO/$VALIDADOS=$WHO=$WHEN" >> "$CONFG"
	echo "REPORTESDIR=$GRUPO/$REPORTES=$WHO=$WHEN" >> "$CONFG"
	echo "LOG=$GRUPO/$LOG=$WHO=$WHEN" >> "$CONFG"
	echo "CONFDIR=$GRUPO/$CONFDIR=$WHO=$WHEN" >> "$CONFG"
	echo -e "\nArchivo de configuracion creado"
}

copiarArchivos (){
	totalEjecutables=`ls "$(pwd)/ejecutables"`
	totalArchivosMaestros=`ls "$(pwd)/maestros"`
	totalArchivosNovedades=`ls "$(pwd)/novedades"`

	echo -e "\nInstalando programas"
	./log.sh -w INSTALADOR -m "Instalando Programas" -i $ARCH_LOG
	echo "-----------------------------------------"
	for ejecutable in ${totalEjecutables[*]}
	do
		cp "$(pwd)/ejecutables/$ejecutable" "$GRUPO/$EJECUTABLES"
		echo "Instalado $(pwd)/ejecutables/$ejecutable en $GRUPO/$EJECUTABLES"
		./log.sh -w INSTALADOR -m "Instalado $(pwd)/ejecutables/$ejecutable en $GRUPO/$EJECUTABLES" -i $ARCH_LOG
	done
	echo "-----------------------------------------"

	echo -e "\nCopiando archivos Maestros"
	echo "-----------------------------------------"
	./log.sh -w INSTALADOR -m "Copiando archivos maestros" -i $ARCH_LOG
	for archivoMaestro in ${totalArchivosMaestros[*]}
	do
		cp "$(pwd)/maestros/$archivoMaestro" "$GRUPO/$MAESTROS"
		echo "Instalado $(pwd)/maestros/$archivoMaestro en $GRUPO/$MAESTROS"
		./log.sh -w INSTALADOR -m "Instalado $(pwd)/maestros/$archivoMaestro en $GRUPO/$MAESTROS" -i $ARCH_LOG
	done
	echo "-----------------------------------------"

	if [ ! -f "$CONFG" ]; then 
		echo -e "\nCopiando Archivos de Novedades"
		echo "-----------------------------------------"
		./log.sh -w INSTALADOR -m "Copiando Archivos de novedades" -i $ARCH_LOG
		for archivoNovedades in ${totalArchivosNovedades[*]}
		do
			cp "$(pwd)/novedades/$archivoNovedades" "$GRUPO/$NOVEDADES"
			echo "Instalado $(pwd)/novedades/$archivoNovedades en $GRUPO/$NOVEDADES"
			./log.sh -w INSTALADOR -m "Instalado $(pwd)/novedades/$archivoNovedades en $GRUPO/$NOVEDADES" -i $ARCH_LOG	
		done
		echo "-----------------------------------------"
	fi
}

darFormatoValido(){
	#Se encarga de eliminar las barras / colacadas de mas
	MAESTROS=$(echo $MAESTROS | sed "s/\/*//" | sed -r "s/\/+/\//g")
	NOVEDADES=$(echo $NOVEDADES | sed "s/\/*//" | sed -r "s/\/+/\//g")
	EJECUTABLES=$(echo $EJECUTABLES | sed "s/\/*//" | sed -r "s/\/+/\//g")
	VALIDADOS=$(echo $VALIDADOS | sed "s/\/*//" | sed -r "s/\/+/\//g")
	REPORTES=$(echo $REPORTES | sed "s/\/*//" | sed -r "s/\/+/\//g")
	ACEPTADOS=$(echo $ACEPTADOS | sed "s/\/*//" | sed -r "s/\/+/\//g")
	RECHAZADOS=$(echo $RECHAZADOS | sed "s/\/*//" | sed -r "s/\/+/\//g")
	LOG=$(echo $LOG | sed "s/\/*//" | sed -r "s/\/+/\//g")
}

ingresarDirectorios(){
	read -p "Ingrese el nombre del directorio de archivos maestros ($MAESTROS_DEFAULT): " MAESTROS	
	MAESTROS="${MAESTROS:-$MAESTROS_DEFAULT}"	read -p "Ingrese el nombre del directorio de archivos de novedades ($NOVEDADES_DEFAULT): " NOVEDADES
	NOVEDADES="${NOVEDADES:-$NOVEDADES_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos ejecutables ($EJECUTABLES_DEFAULT): " EJECUTABLES
	EJECUTABLES="${EJECUTABLES:-$EJECUTABLES_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos de validados ($VALIDADOS_DEFAULT): " VALIDADOS
	VALIDADOS="${VALIDADOS:-$VALIDADOS_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos de reportes ($REPORTES_DEFAULT): " REPORTES
	REPORTES="${REPORTES:-$REPORTES_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos de aceptados ($ACEPTADOS_DEFAULT): " ACEPTADOS
	ACEPTADOS="${ACEPTADOS:-$ACEPTADOS_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos de rechazados ($RECHAZADOS_DEFAULT): " RECHAZADOS
	RECHAZADOS="${RECHAZADOS:-$RECHAZADOS_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos de log ($LOG_DEFAULT): " LOG
	LOG="${LOG:-$LOG_DEFAULT}"

	#Elimina las // que se coloquen
	darFormatoValido

	#Almaceno los directorios
	MAESTROS_DEFAULT=$MAESTROS
	NOVEDADES_DEFAULT=$NOVEDADES
	EJECUTABLES_DEFAULT=$EJECUTABLES
	VALIDADOS_DEFAULT=$VALIDADOS
	REPORTES_DEFAULT=$REPORTES
	ACEPTADOS_DEFAULT=$ACEPTADOS
	RECHAZADOS_DEFAULT=$RECHAZADOS
	LOG_DEFAULT=$LOG
}

inicializarVariablesDefecto(){
	MAESTROS_DEFAULT="maestros"
	NOVEDADES_DEFAULT="novedades"	
	EJECUTABLES_DEFAULT="ejecutables"
	VALIDADOS_DEFAULT="validados"
	REPORTES_DEFAULT="reportes"
	ACEPTADOS_DEFAULT="aceptados"
	RECHAZADOS_DEFAULT="rechazados"
	LOG_DEFAULT="log"
	CONFDIR="dirconf"
}


validarDirectorios (){
	#La idea es comparar todos los elementos del vector y contar cuando hay una igualdad
	#Este contador debe ser igual a la cantidad de elementos del vector
	#dado que al compararse todos los elementos con todos se comparan los que son iguales
	
	contador=0 #Primer Elemento a comparar
	directorios1=(${CONFDIR} ${MAESTROS} ${NOVEDADES} ${EJECUTABLES} ${VALIDADOS} ${REPORTES} ${ACEPTADOS} ${RECHAZADOS} ${LOG})
	error=0
	for directorio1 in ${directorios1[*]}
	do
		for directorio2 in ${directorios1[*]}
		do 
			if [ $directorio1 = $directorio2 ]; then
				let contador=contador+1
			fi
		done
	done
	len=${#directorios1[@]}
	if [ $contador -gt $len ]; then
		error=1
	fi
}

cargarDirectorios(){
	#Se cargan los directorios desde el archivo de configuración
	echo -e "\nSe ha detectado una instalación previa"
	echo -e "\nSe sobreescribieron los archivos maestros y ejecutables"
	EJECUTABLES=$(grep '^BINARIOS' "$CONFG" | cut -d '=' -f 2  | cut -d '/' -f 5-)
    MAESTROS=$(grep '^MAESTROS' "$CONFG" | cut -d '=' -f 2  | cut -d '/' -f 5-)
    echo -e "Directorio de ejecutables $EJECUTABLES"
    echo -e "Directorio de maestros $MAESTROS"
    ./log.sh -w INSTALADOR -m "Se cargaron los directorios desde el archivo de configuracion Maestros: $GRUPO/$MAESTROS Ejecutables: $GRUPO/$EJECUTABLES" -i $ARCH_LOG
}

definirDirectorios (){
	OPCION="n"
	inicializarVariablesDefecto
	if [ ! -f "$CONFG" ]; then #Si no existe el archivo de configuracion
		while [ $OPCION != "s" ]; do
    		ingresarDirectorios
    		confirmarDirectorios
   			validarDirectorios
   			if [ $error = 1 ]; then
  				OPCION="n"
  				echo -e "\n Error no se puede ingresar directorios con nombres duplicados"
  				./log.sh -w INSTALADOR -m "Se ingresaron nombres duplicados en los directorios" -e $ARCH_LOG		
  			fi
		done
	else
		cargarDirectorios
	fi
}

confirmarDirectorios(){	
	echo -e "A continuación se va a crear la siguiente estructura en el directorio de instalación"
	echo "Directorio de archivos maestros: $MAESTROS "	
	echo "Directorio de archivos ejecutables: $EJECUTABLES "	
	echo "Directorio de archivos de novedades: $NOVEDADES "	
	echo "Directorio de archivos de validados: $VALIDADOS "	
	echo "Directorio de archivos de reportes: $REPORTES "	
	echo "Directorio de archivos de aceptados: $ACEPTADOS "	
	echo "Directorio de archivos de rechazados: $RECHAZADOS "	
	echo "Directorio de archivos de log: $LOG "
	echo -e "\nEstá de acuerdo con estos datos (s/n)"
	./log.sh -w INSTALADOR -m "Seleccionó el nombre de los directorios" -i $ARCH_LOG
	read OPCION	
}

crearDirectorios(){
	directorios=(${CONFDIR} ${MAESTROS} ${NOVEDADES} ${EJECUTABLES} ${VALIDADOS} ${REPORTES} ${ACEPTADOS} ${RECHAZADOS} ${LOG})

	echo -e "\nCreando Estructuras de directorio.." 
    echo "-----------------------------------------"
	./log.sh -w INSTALADOR -m "Creando estructura de directorio" -i $ARCH_LOG
	for directorio in ${directorios[*]}
	do
		echo "Creando $directorio"
		mkdir -p "$GRUPO/$directorio"
		./log.sh -w INSTALADOR -m "Directorio Creado $directorio" -i $ARCH_LOG
	done
	echo "-----------------------------------------"
}

crearArchivoConfiguracion()
{
	if [ $HAYINSTALACION = "false" ]; then
		./log.sh -w INSTALADOR -m "Se creo el archivo de configuracion en $CONFG" -i $ARCH_LOG
 		escribirConfig
 		./log.sh -w INSTALADOR -m "Se finaliza la instalacion" -i $ARCH_LOG
	else
		./log.sh -w INSTALADOR -m "Se finaliza la reinstalación" -i $ARCH_LOG
	fi
}

detectarInstalacion(){
 if [ -f "$CONFG" ]; then
 	HAYINSTALACION="true"
 	./log.sh -w INSTALADOR -m "Se inicia reinstalación" -i $ARCH_LOG
 else 
 	HAYINSTALACION="false"
 	./log.sh -w INSTALADOR -m "Se inicia instalación" -i $ARCH_LOG
 fi
}

instalacion (){
		detectarInstalacion
		definirDirectorios
		crearDirectorios
		copiarArchivos
		crearArchivoConfiguracion
		echo "Fin de instalacion"
}

versionPerl(){
	echo -n "Version de Perl : "
	perl -e 'print $ ];';
	perl -e 'print "\n";'
	./log.sh -w INSTALADOR -m "Se verifico la version de Perl" -i $ARCH_LOG
}

verificarSistema(){
	if [ -d "$GRUPO" ]; then 
		echo -e "\nAplicación ya instalada"
		echo -e "\nArchivo de configuración"
		echo "-----------------------------------------"
		cat $CONFG;
		echo "-----------------------------------------"
		./log.sh -w INSTALADOR -m "Se verifico que la aplicación ya estaba instalada" -i $ARCH_LOG
	else
		echo -e "\nAplicación no instalada"
		./log.sh -w INSTALADOR -m "Se verifico que la aplicación ya no estaba instalada" -i $ARCH_LOG
	fi
}

# Seleccion de opciones.
# Es el inicio del script
clear
echo "-----------------------------------------"
echo -e "Bienvenido al sistema de instalacion"
echo "-----------------------------------------"
for param in "$@"
do
	if [ $param = "-p" ]; then
		versionPerl
	elif [ $param = "-t" ]; then
		verificarSistema
	elif [ $param = "-i" ]; then
		instalacion	
	else
		echo -e "Error: El parametro ingresado es erroneo, \nRecuerde que los permitidos son -p -t -i"
	fi
done

if [ $# == 0 ]; then 
	echo -e "Error: debe ingresar algun parametro"
	./log.sh -w INSTALADOR -m "Se ejecuto el instalador sin parametros" -e $ARCH_LOG
	echo -e "Error: El parametro ingresado es erroneo, \nRecuerde que los permitidos son -p -t -i"
fi

if [ -d "$GRUPO/dirconf" ]; then
	cat $ARCH_LOG >> "$GRUPO/dirconf/$ARCH_LOG"
	rm $ARCH_LOG
fi
