	#!/bin/bash

GRUPO=~/grupo05
CONFG="$GRUPO/dirconf/config.cnf"

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
	echo "Archivo de configuracion creado"
}

copiarArchivos (){
	totalEjecutables=`ls "$(pwd)/ejecutables"`
	totalArchivosMaestros=`ls "$(pwd)/maestros"`
	totalArchivosNovedades=`ls "$(pwd)/novedades"`

	echo -e "\nInstalando programas"
	echo "-----------------------------------------"
	for ejecutable in ${totalEjecutables[*]}
	do
		cp "$(pwd)/ejecutables/$ejecutable" "$GRUPO/$EJECUTABLES"
		echo "Instalado $(pwd)/ejecutables/$ejecutable en $GRUPO/$EJECUTABLES"
	done
	echo "-----------------------------------------"

	echo -e "\nCopiando archivos Maestros"
	echo "-----------------------------------------"
	for archivoMaestro in ${totalArchivosMaestros[*]}
	do
		cp "$(pwd)/maestros/$archivoMaestro" "$GRUPO/$MAESTROS"
		echo "Instalado $(pwd)/maestros/$archivoMaestro en $GRUPO/$MAESTROS"
	done
	echo "-----------------------------------------"

	echo -e "\nCopiando Archivos de Novedades"
	echo "-----------------------------------------"
	for archivoNovedades in ${totalArchivosNovedades[*]}
	do
		cp "$(pwd)/novedades/$archivoNovedades" "$GRUPO/$NOVEDADES"
		echo "Instalado $(pwd)/novedades/$archivoNovedades en $GRUPO/$NOVEDADES"
	done
	echo "-----------------------------------------"
}


ingresarDirectorios(){
	read -p "Ingrese el nombre del directorio de archivos maestros ($MAESTROS_DEFAULT): " MAESTROS	
	MAESTROS="${MAESTROS:-$MAESTROS_DEFAULT}"
	MAESTROS_DEFAULT=$MAESTROS

	read -p "Ingrese el nombre del directorio de archivos de novedades ($NOVEDADES_DEFAULT): " NOVEDADES
	NOVEDADES="${NOVEDADES:-$NOVEDADES_DEFAULT}"
	NOVEDADES_DEFAULT=$NOVEDADES

	read -p "Ingrese el nombre del directorio de archivos ejecutables ($EJECUTABLES_DEFAULT): " EJECUTABLES
	EJECUTABLES="${EJECUTABLES:-$EJECUTABLES_DEFAULT}"
	EJECUTABLES_DEFAULT=$EJECUTABLES

	read -p "Ingrese el nombre del directorio de archivos de validados ($VALIDADOS_DEFAULT): " VALIDADOS
	VALIDADOS="${VALIDADOS:-$VALIDADOS_DEFAULT}"
	VALIDADOS_DEFAULT=$VALIDADOS

	read -p "Ingrese el nombre del directorio de archivos de reportes ($REPORTES_DEFAULT): " REPORTES
	REPORTES="${REPORTES:-$REPORTES_DEFAULT}"
	REPORTES_DEFAULT=$REPORTES

	read -p "Ingrese el nombre del directorio de archivos de aceptados ($ACEPTADOS_DEFAULT): " ACEPTADOS
	ACEPTADOS="${ACEPTADOS:-$ACEPTADOS_DEFAULT}"
	ACEPTADOS_DEFAULT=$ACEPTADOS

	read -p "Ingrese el nombre del directorio de archivos de rechazados ($RECHAZADOS_DEFAULT): " RECHAZADOS
	RECHAZADOS="${RECHAZADOS:-$RECHAZADOS_DEFAULT}"
	RECHAZADOS_DEFAULT=$RECHAZADOS

	read -p "Ingrese el nombre del directorio de archivos de log ($LOG_DEFAULT): " LOG
	LOG="${LOG:-$LOG_DEFAULT}"
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

definirDirectorios (){
	OPCION="n"
	inicializarVariablesDefecto
	while [  $OPCION != "s" ]; do
    	ingresarDirectorios
    	confirmarDirectorios
    	clear
	done
}

confirmarDirectorios(){
	clear
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
	read OPCION	
}

crearDirectorios(){
	directorios=(${CONFDIR} ${MAESTROS} ${NOVEDADES} ${EJECUTABLES} ${VALIDADOS} ${REPORTES} ${ACEPTADOS} ${RECHAZADOS})
	clear
	echo -e "\nCreando Estructuras de directorio.." 
    echo "-----------------------------------------"
	for directorio in ${directorios[*]}
	do
		echo "Creando $directorio"
		mkdir -p "$GRUPO/$directorio"
	done
	echo "-----------------------------------------"
}

crearArchivoConfiguracion()
{
	if [ ! -f "$CONFG" ]; then
 		escribirConfig
	fi
}

instalacion (){
	definirDirectorios
	crearDirectorios
	crearArchivoConfiguracion
	copiarArchivos
	echo "Fin instalacion"
}

versionPerl(){
	echo -n "Version de Perl : "
	perl -e 'print $ ];';
	perl -e 'print "\n";'
}

verificarSistema(){
	if [ -d "$GRUPO" ]; then 
		echo -e "\nAplicación ya instalada"
		echo -e "\nArchivo de configuración"
		echo "-----------------------------------------"
		cat $CONFG;
		echo "-----------------------------------------"
	else
		echo -e "\nAplicación no instalada"
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
fi