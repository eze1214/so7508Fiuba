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

	echo "Instalando programas"

	for ejecutable in ${totalEjecutables[*]}
	do
		cp "$(pwd)/ejecutables/$ejecutable" "$GRUPO/$EJECUTABLES"
	done

	echo "Copiando archivos Maestros"

	for archivoMaestro in ${totalArchivosMaestros[*]}
	do
		cp "$(pwd)/maestros/$archivoMaestro" "$GRUPO/$MAESTROS"
	done

	for archivoNovedades in ${totalArchivosNovedades[*]}
	do
		cp "$(pwd)/novedades/$archivoNovedades" "$GRUPO/$NOVEDADES"
	done
}


definirDirectoriosyParametros (){
	echo "Creando archivos de directorio.."
	MAESTROS_DEFAULT="maestros"
	NOVEDADES_DEFAULT="novedades"	
	EJECUTABLES_DEFAULT="ejecutables"
	DIRPPAL=10
	VALIDADOS_DEFAULT="validados"
	REPORTES_DEFAULT="reportes"
	ACEPTADOS_DEFAULT="aceptados"
	RECHAZADOS_DEFAULT="rechazados"
	LOG_DEFAULT="log"
	CONFDIR="dirconf"

	read -p "Ingrese el nombre del directorio de archivos maestros ($MAESTROS_DEFAULT): " MAESTROS	
	MAESTROS="${MAESTROS:-$MAESTROS_DEFAULT}"

	read -p "Ingrese el nombre del directorio de archivos de novedades ($NOVEDADES_DEFAULT): " NOVEDADES
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
}

crearDirectorios(){
	directorios=(${CONFDIR} ${MAESTROS} ${NOVEDADES} ${EJECUTABLES} ${VALIDADOS} ${REPORTES} ${ACEPTADOS} ${RECHAZADOS})
	
	echo "Creando Estructuras de directorio.." 

	for directorio in ${directorios[*]}
	do
		echo "Creando $directorio"
		mkdir -p "$GRUPO/$directorio"
	done
}

crearArchivoConfiguracion(){
	if [ ! -f "$CONFG" ]; then
 		escribirConfig
	fi
}


instalacion (){
	definirDirectoriosyParametros
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
		echo "Aplicación ya instalada"
		echo "Archivo de configuración"
		cat $CONFG;
	else
		echo "no instalado"
	fi
}

# Seleccion de opciones.
# Es el inicio del script
for param in "$@"
do
	if [ $param = "-p" ]; then
		versionPerl
	elif [ $param = "-t" ]; then
		verificarSistema
	elif [ $param = "-i" ]; then
		instalacion	
	fi
done