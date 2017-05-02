function ambienteInicializado(){
	if [ "${GRUPO}" == "" ]; then	
		return 1
	fi

	if [ "${BINARIOS}" == "" ]; then	
		return 1
	fi

	if [ "${MAESTROS}" == "" ]; then	
		return 1
	fi

	if [ "${NOVEDADES}" == "" ]; then	
		return 1
	fi

	if [ "${ACEPTADOS}" == "" ]; then	
		return 1
	fi

	if [ "${RECHAZADOS}" == "" ]; then	
		return 1
	fi

	if [ "${VALIDADOSDIR}" == "" ]; then	
		return 1
	fi

	if [ "${REPORTESDIR}" == "" ]; then	
		return 1
	fi

	if [ "${LOG}" == "" ]; then	
		return 1
	fi

	if [ "${MAESTRO_DE_BANCOS}" == "" ]; then	
		return 1
	fi
	return 0
}