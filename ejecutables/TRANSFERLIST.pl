#!/usr/bin/perl 
use Getopt::Long;
use Scalar::Util qw(looks_like_number);


#Hashes
%transferenciasOrigenDestinoHash;
%transferenciasOrigenFechaHash;
%transferenciasDestinoFechaHash;
%cbuOrigenDestinoHash;

@arrayResultQuery=();
$lastId =0;

# Variables de argumentos.
$help = 0;
$fileIn = '';
@aniomes =(); #Guarda el filtro de aniomes


# Flags de filtros
$statTypeRanking=0;
$statFilterType=0;
$writeToFileFlag=0;
$rangeOfaniomes=();
$matchStrFlag=0;
$registrosResultantes=0;

$printFlag=0;


$querySelectionChoice = "*";
$filtroFuentesSelection = "*";
$filtroEntidadOrigenSelection = "*";
$filtroEntidadDestinoSelection = "*";
$filtroEstadoSelection = "*";
$filtroFechasSelection = "*";
$filtroImporteMinSelection = "0";
$filtroImporteMaxSelection = "*";


# Seteo las variables en base a la informacion que brinda el entorno
sub parseConfig{

	$repoDir= "/home/ubuntu1610/grupo05/reportes";
	#$repoDir= $ENV{"GRUPO5_REPORTESDIR"};#"/home/ubuntu1610/grupo05/reportes";

	if($repoDir eq "")
	{
		print $repoDir;
		showErrorInit();
	}
	else
	{
		$transfer = $repoDir."/transfer/";
		$balancesDir = $repoDir. "/balances/";
		$listadosDir = $repoDir. "/listados/";
		$rankingDir = $repoDir. "/ranking/";	
	}
}

#Parsea los argumentos ingresados por el usuario
sub parseArguments()
{
	@myArgs = @ARGV;
	GetOptions('help|h' => \$help, 
				"query|c" => \$fileIn,
				);
	if( $help == 1 ) 
	{
		# Si encuentra -h imprime ayuda y sale
		showHelpMenu();
		exit 1;
	}

	if($fileIn ==1)
	{
		mainLoadFilteredTransfer();
	}

}

#cargo los archivos de transferencias según el filtro que se indique
sub mainLoadFilteredTransfer()
{
		showFilterType();
		while($statFilterType <1 or $statFilterType >3)
		{
			showErrorSelection();
			showFilterType();
		}
		processFilterTypeSelection();
		makeStatQuery();
		showQuerySelection();
}


#Menu para mostrar las opciones de tipo de ranking
sub showFilterType()
{
print "\n\tTIPO DE FILTRO
	-----------------------------------------------------------------------
	1) Una fecha
	2) Un rango de fechas
	3) Todas las fechas
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$statFilterType = <>;
}

#Procesa la opción que se seleccionó en showFilterType y pide fechas según lo seleccionado
sub processFilterTypeSelection()
{
	if($statFilterType==1)
	{
		my $dateValid=0;
		while($dateValid == 0)
		{
			print "\tFecha (aaaammdd): ";
			chomp($rangeOfaniomes[0] = <>);
			$dateValid = validateDateFormat($rangeOfaniomes[0]);
			if($dateValid == 0)
			{
				showErrorFormatDate();
			}
		}
	}
	elsif($statFilterType==2)
	{
		my $dateValid=0;
		while($dateValid==0)
		{
			while($dateValid==0)
			{
				print "\tFecha mínima (aaaammdd): ";
				chomp($rangeOfaniomes[0] = <>);
				$dateValid= validateDateFormat($rangeOfaniomes[0]);
				if($dateValid == 0)
				{
					showErrorFormatDate();
				}
			}
			$dateValid = 0;
			while($dateValid==0)
			{
				print "\tFecha máxima (aaaammdd): ";
				chomp($rangeOfaniomes[1] = <>);
				$dateValid= validateDateFormat($rangeOfaniomes[1]);
				if($dateValid == 0)
				{
					showErrorFormatDate();
					if($rangeOfaniomes[0] >$rangeOfaniomes[1])
					{
						showErrorFormatSecondDate();
					}
				}
			}
		}

	}
	elsif($statFilterType == 3)
	{
		$rangeOfaniomes[0]="*";
	}else
	{
		$statFilterType=0;
	}
}


##################################################################
############ FILTRO INICIAL POR FECHAS ###########################

#Acá cargo todas las transferencias en los hash para después mostrarlas según los filtros
sub makeStatQuery()
{
	opendir(DIR,$procDir);
	my @filesOFTP = readdir(DIR);
	my @workFiles=();
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		if(fileMatchAnioMesFilter($aFile))
		{
			push @workFiles, $aFile;
		}
	}

	foreach(@workFiles)
	{
		my $aFile = $_;
		my $idOficina = substr $aFile, 0, 3;
		$workFilePath = $procDir."/".$aFile;
		open F_WORKFILEPATH, "<", "$workFilePath" or die "No se pudo abrir el archivo de $workFilePath";


		#Recorro secuencialmente los archivos y cargo los hash
		while(my $line = <F_WORKFILEPATH>)
		{
			chomp;
			($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $line);
			
			if($eOrigen ne $eDestino)
			{
				$transferenciasOrigenDestinoHash{$eOrigen}{$eDestino} = $line;
				$transferenciasOrigenFechaHash{$eOrigen}{$fechaTransf} = $line;
				$transferenciasDestinoFechaHash{$eDestino}{$fechaTransf} = $line;
				$cbuOrigenDestinoHash{$cbuOrigen}{$cbuDestino} = $line;
			}	
		}
		close (F_WORKFILEPATH);
	}
}


#Selecciono los archivos que cumplen con el filtro de fechas
sub fileMatchAnioMesFilter()
{

	if($statFilterType ==3)
	{
		return 1;
	}
	else
	{
		my ($fileName) = @_;
		my $aDate= substr $fileName, 4,8;
		my $anio= substr $aDate, 0,4;
		my $mes = substr $aDate, 4,2;
		my $dia = substr $aDate, 6,2;

		my $rangeAnio= substr $rangeOfaniomes[0], 0,4;
		my $rangeMes = substr $rangeOfaniomes[0], 4,2;

		if($statFilterType ==1)
		{	
			if ($rangeAnio eq $anio and $rangeMes eq $mes)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		else
		{
			my $rangeAnioMax= substr $rangeOfaniomes[1], 0,4;
			my $rangeMesMax = substr $rangeOfaniomes[1], 4,2;
			if ($rangeAnio <= $anio and $rangeMes <= $mes and $anio <= $rangeAnioMax and $mes <= $rangeMesMax )
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}	
	}
}




########################################################
################## FILTROS #############################


sub showQuerySelection()
{
print "\n\tSELECCION DE CONSULTA
	-----------------------------------------------------------------------
	1) Filtro por fuente (una, varias, todas)
	2) Filtro por Entidad origen (una, varias, todas)
	3) Filtro por Entidad destino (una, varias, todas)
	4) Filtro por Estado (uno o ambos)
	5) Filtro por fecha de la transferencia (una, rango de fechas)
	6) Filtro por importe (entre valor x – valor y)
	7) Realizar Consulta
	8) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$querySelectionChoice = <>;

	if ($querySelectionChoice == 1)
	{
		showFuenteFilterMenu();
	}
	elsif($querySelectionChoice == 2)
	{
		showEntidadOrigenFilterMenu();
	}	
	elsif($querySelectionChoice == 3)
	{
		showEntidadDestinoFilterMenu();
	}
	elsif($querySelectionChoice == 4)
	{
		showEstadoFilterMenu();
	}
	elsif($querySelectionChoice == 5)
	{
		showFechaTransfFilterMenu();
	}
	elsif($querySelectionChoice == 6)
	{
		showImporteFilterMenu();
	}
	elsif($querySelectionChoice == 7)
	{
		showQueryMenu();
		if($typeOfListSelection == 8)
		{
			exit 0;
		}
		elsif($typeOfListSelection > 8)
		{
			showErrorSelection();
		}
		elsif($typeOfListSelection < 7)
		{
			showDetailsMenu();
			if($typeOfDetailSelection == 4)
			{
				exit 0;
			}
			elsif($typeOfDetailSelection > 4)
			{
				showErrorSelection();
			}
			elsif($typeOfDetailSelection <3)
			{
				showOutputMenu();
				if($typeOfOutputSelection == 5)
				{
					exit 0;
				}
				elsif($typeOfListSelection > 5)
				{
					showErrorSelection();
				}
				elsif($typeOfListSelection < 4)
				{
					getQuery();
					showQueryResult();
				}
			}
		}
	}
	else
	{
		exit 0;
	}		

	showQuerySelection();

}


sub showFuenteFilterMenu()
{
print "\n\tINGRESE LAS FUENTES SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODOS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroFuentesSelection = <>);

	my @fuentesSel = split(' ',$filtroFuentesSelection);
	@fuentesValidadas=();
	foreach my $unaFuente (@fuentesSel)
	{
			push @fuentesValidadas, $unaFuente;		
	}

	if(scalar(@fuentesValidadas) == 0)
	{
		showErrorSelection();
		$filtroFuentesSelection = "*";
	}

}

sub showEntidadOrigenFilterMenu()
{
	print "\n\tINGRESE LAS ENTIDADES ORIGEN SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroEntidadOrigenSelection = <>);

	my @entidadesOrgenSel = split(' ',$filtroEntidadOrigenSelection);
	@entidadesOrigenValidadas=();
	foreach my $unaEntidadOrigen (@entidadesOrgenSel)
	{
			push @entidadesOrigenValidadas, $unaEntidadOrigen;		
	}

	if(scalar(@entidadesOrigenValidadas) == 0)
	{
		showErrorSelection();
		$filtroEntidadOrigenSelection = "*";
	}
}


sub showEntidadDestinoFilterMenu()
{
	print "\n\tINGRESE LAS ENTIDADES DESTINO SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroEntidadDestinoSelection = <>);

	my @entidadesDestinoSel = split(' ',$filtroEntidadDestinoSelection);
	@entidadesDestinoValidadas=();
	foreach my $unaEntidadDestino (@entidadesDestinoSel)
	{
			push @entidadesDestinoValidadas, $unaEntidadDestino;		
	}

	if(scalar(@entidadesDestinoValidadas) == 0)
	{
		showErrorSelection();
		$filtroEntidadDestinoSelection = "*";
	}
}


sub showEstadoFilterMenu()
{
	print "\n\tINGRESE UN ESTADO (Anulada o Pendiente)
	(PARA FILTRAR POR AMBOS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroEstadoSelection = <>);

	my @estadoSel = split(' ',$filtroEstadoSelection);
	@estadosValidados=();
	foreach my $unEstado (@estadoSel)
	{
		if($unEstado eq "Anulada" or $unEstado eq "Pendiente")
		{
			push @estadosValidados, $unEstado;		
		}
	}

	if(scalar(@estadosValidados) == 0)
	{
		showErrorSelection();
		$filtroEstadoSelection = "*";
	}
}



sub	showFechaTransfFilterMenu()
{
print "\n\tTIPO DE FILTRO
	-----------------------------------------------------------------------
	1) Una fecha
	2) Un rango de fechas
	3) Todas las fechas
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$fechaTransfFilterType = <>;
	
	if($fechaTransfFilterType==1)
	{
		my $dateValid=0;
		while($dateValid == 0)
		{
			print "\tFecha (aaaammdd): ";
			chomp($filtroFechasSelection[0] = <>);
			$dateValid = validateDateFormat($filtroFechasSelection[0]);
			if($dateValid == 0)
			{
				showErrorFormatDate();
			}
			else
			{
				@fechasTransfValidados=();
				push @fechasTransfValidados, $filtroFechasSelection[0];
			}
		}
	}
	elsif($fechaTransfFilterType==2)
	{
		my $dateValid=0;
		while($dateValid==0)
		{
			while($dateValid==0)
			{
				print "\tFecha mínima (aaaammdd): ";
				chomp($filtroFechasSelection[0] = <>);
				$dateValid= validateDateFormat($filtroFechasSelection[0]);
				if($dateValid == 0)
				{
					showErrorFormatDate();
				}
				else
				{
					@fechasTransfValidados=();
					push @fechasTransfValidados, $filtroFechasSelection[0];
				}
			}
			$dateValid = 0;
			while($dateValid==0)
			{
				print "\tFecha máxima (aaaammdd): ";
				chomp($filtroFechasSelection[1] = <>);
				$dateValid= validateDateFormat($filtroFechasSelection[1]);
				if($dateValid == 0)
				{
					showErrorFormatDate();
					if($filtroFechasSelection[0] >$filtroFechasSelection[1])
					{
						showErrorFormatSecondDate();
					}
				}
				else
				{
					@fechasTransfValidados=();
					push @fechasTransfValidados, $filtroFechasSelection[1];
				}
			}
		}

	}
	else($fechaTransfFilterType == 3)
	{
		@fechasTransfValidados=();
		$filtroFechasSelection[0]="*";
		push @fechasTransfValidados, $filtroFechasSelection[0];
	}

}

#Pido información del importe mínimo
sub showImporteFilterMenu()
{
print "\n\tINGRESE EL IMPORTE MINIMO (El mínimo es 0)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroImporteMinSelection = <>);
	
	if($filtroImporteMinSelection =~ /[0-9]/)
	{
		showImporteMaxFilterMenu()
	}else
	{
		showErrorSelection();
		$filtroImporteMinSelection = "0";
	}
	



}


sub showImporteMaxFilterMenu()
{
print "\n\tINGRESE EL IMPORTE MAXIMO
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroImporteMaxSelection = <>);

	if($filtroImporteMaxSelection =~ /[0-9]/)
	{

	}
	else
	{
		showErrorSelection();
		$filtroImporteMinSelection = "0";
		$filtroImporteMaxSelection = "*";
	}
}


####################################################################
################## GENERACION DE CONSULTAS #########################
sub showQueryMenu()
{
print "\n\tSELECCIONAR LISTADO
	-----------------------------------------------------------------------
	1) Listado por entidades origen
	2) Listado por entidades destino
	3) Balance por entidad
	4) Balance entre dos entidades
	5) Listado por CBU
	6) Ranking de entidades
	7) Volver al menú de filtro
	8) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$typeOfListSelection = <>;
}


sub showDetailsMenu()
{
print "\n\tOPCIONES DE DETALLES
	-----------------------------------------------------------------------
	1) Mostrar detalles
	2) No mostrar detalles
	3) Volver al menú de selección de filtro
	4) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$typeOfDetailSelection = <>;
}

sub showOutputMenu()
{
print "\n\tOPCIONES DE LISTADO
	-----------------------------------------------------------------------
	1) Por pantalla
	2) Por archivo
	3) Por pantalla y archivo
	4) Volver al menú de selección de filtro
	5) Salir
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	$typeOfOutputSelection = <>;
}


sub getQuery()
{
	getQueryEntidadesOrigen();
	getQueryEntidadesDestino();
	getQueryBalancePorEntidad();
	getQueryBalanceEntreEntidades();
	getQueryPorCBU();
	showRanking();
}


sub getQueryEntidadesOrigen()
{
	print "\n\tINGRESE LAS ENTIDADES DESTINO SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($queryEntidadDestinoSelection = <>);

	my @entidadesDestinoSel = split(' ',$queryEntidadDestinoSelection);
	@entidadesDestinoAListar=();
	foreach my $unaEntidadDestino (@entidadesDestinoSel)
	{
		if (exists $transferenciasOrigenFechaHash{$unaEntidadDestino})
		{
			push @entidadesDestinoAListar, $unaEntidadDestino;
		}	
	}

foreach my $unaEntidadDestinoAListar (@entidadesDestinoAListar)
{
	print "ENTIDAD: $unaEntidadDestinoAListar\n";
	foreach my $unaFechaDeTransferencia (sort keys %transferenciasOrigenFechaHash{$unaEntidadDestinoAListar}) 
	{
		$transferenciasDeUnaFecha =$transferenciasOrigenFechaHash{$unaEntidadDestinoAListar}{$unaFechaDeTransferencia};
		print "FECHA: $unaFechaDeTransferencia\n";
    	foreach my $unaTransferencia (@transferenciasDeUnaFecha)
    	{
    		#if() VALIDACIONES DE FILTRO
    		print "$unaTransferencia\n";    		
    	}
	}
}

}



sub showQueryResult()
{
	my @sortedResult = @arrayResultQuery;

	if( $typeOfOutputSelection == 2 or $typeOfOutputSelection == 3)
	{
		my $filename="";
		if($typeOfListSelection == 1 or $typeOfListSelection == 2 or $typeOfListSelection == 5)
		{
			$filename = $listadosDir."unListado";	
		}
		elsif($typeOfListSelection == 3 or $typeOfListSelection == 4)
		{
			$filename = $balancesDir."unBalance";	
		}
		elsif($typeOfListSelection == 6)
		{
			$filename = $rankingDir."unBalance";
		}
		open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
		print $fh @sortedResult;
		close $fh;
print "\n\tSE GENERO EL ARCHIVO $filename
	-----------------------------------------------------------------------\n";	
	}

	if($typeOfOutputSelection == 1 or $typeOfOutputSelection == 3)
	{
		print "@sortedResult\n";
	}
}




####################################################################
################## RANKING DE TRANSFERENCIAS #######################






##############################################################
########################## UTILS ############################

#Valido que la fecha sea del tipo AAAAMMDD
sub validateDateFormat()
{
	my ($aDate) = @_;

	if(length($aDate) != 8)
	{
		return 0;
	}
	if(looks_like_number($aDate)==0)
	{
		return 0;
	}

	my $anio = substr $aDate, 0, 4; 
	my $mes = substr $aDate, 4, 2; 
	my $dia = substr $aDate, 6, 2;

	if($anio >2017 or $mes > 12 or $mes <1 or $dia > 31 or $dia < 1)
	{
		return 0;
	}
	
	return 1;
	
}




#################################################################
######################### Mensajes de error ####################
sub showErrorSelection()
{
print "\n\t-----------------------------------------------------------------------
	SELECCION INCORRECTA - INTENTE NUEVAMENTE
	-----------------------------------------------------------------------\n";
}



sub showErrorFormatDate()
{
print "\n\t-----------------------------------------------------------------------
	FORMATO DE FECHA INCORRECTO - INTENTE NUEVAMENTE CON EL FORMATO (AAAAMMDD)
	-----------------------------------------------------------------------\n";
}

sub showErrorFormatSecondDate()
{
print "\n\t-----------------------------------------------------------------------
	EL PERIODO MAXIMO NO PUEDE SER MENOR AL PERIODO MINIMO: $rangeOfaniomes[0]
	-----------------------------------------------------------------------\n";
}


####################################################################################################################
#######################################    AYUDA     ###############################################################
####################################################################################################################
#Muestra la ayuda del comando
sub showHelpMenu()
{
# Imprime informacion de uso de la herramienta
# Usage:	listarT.pl -<c|e|h|s|k|p|t>
#	
	print "\n\tPrograma: AFLIST.pl - Grupo 5 - GNU GPLv3
	Descripcion: Genera reportes y rankings de transferencias entre entidades 
	con la aplicación de distintos filtros.			 
	USAGE: TRANSFERLIST.pl -<h|c> 
	-----------------------------------------------------------------------\n
	-h : Imprime esta ayuda
	-c : Realiza consulta sobre transferencias aplicando filtros
	-----------------------------------------------------------------------\n
	Ejemplo:
		TRANSFERLIST.pl -h
		TRANSFERLIST.pl -c
	\n";
	exit 0;

}



sub showErrorInit()
{
print "\n\t-----------------------------------------------------------------------
	NO SE HA INICIALIZADO EL AMBIENTE - INTENTE NUEVAMENTE LUEGO DE EJECUTAR EL INSTALADOR
	-----------------------------------------------------------------------\n";
}


#main();
parseConfig();
parseArguments();