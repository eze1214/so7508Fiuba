#!/bin/bash

#########################################
#					#
#	Sistemas Operativos 75.08	#
#	Grupo: 	5			#
#	Nombre:	global.sh		#
#					#
#########################################

#Devuelve la ruta de la variable a buscar

CONFDIR=`pwd | sed s#/bin#/confdir#g`
export GRUPO=`grep -A 0 GRUPO $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export BINARIOS=`grep -A 0 BINARIOS $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export MAESTROS=`grep -A 0 MAESTROS $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export NOVEDADES=`grep -A 0 NOVEDADES $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export ACEPTADOS=`grep -A 0 ACEPTADOS $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export RECHAZADOS=`grep -A 0 RECHAZADOS $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export VALIDADOSDIR=`grep -A 0 VALIDADOSDIR $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export REPORTESDIR=`grep -A 0 REPORTESDIR $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
export LOG=`grep -A 0 LOG $CONFDIR/config.cnf | sed "s/\(^.*\)\(=.*\)\(=.*\)\(=.*\)/\2/g" | sed s/=//g`
