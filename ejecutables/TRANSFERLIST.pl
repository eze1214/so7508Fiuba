#!/usr/bin/perl 
use Getopt::Long;
use Scalar::Util qw(looks_like_number);


#Hashes
%transferenciasOrigenDestinoHash;
%transferenciasOrigenFechaHash;
%transferenciasDestinoFechaHash;
%cbuOrigenHash;
%cbuDestinoHash;
%rankingRecibieronHash;
%rankingEmitieronHash;


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
$filtroImporteMinSelection = "-9999999999";
$filtroImporteMaxSelection = "*";


# Seteo las variables en base a la informacion que brinda el entorno
sub parseConfig{

	#$repoDir= "/home/ubuntu1610/grupo05/reportes";
	$repoDir=$ENV{REPORTESDIR};
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

	if($fileIn == 1)
	{
		mainLoadFilteredTransfer();
	}

	if($fileIn != 1 or $help != 1)
	{
		showErrorSelection();
		showHelpMenu();
		exit 1;
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
	blankAllQuerySelection();
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
	}
	else
	{
		$statFilterType=0;
	}
}


##################################################################
############ FILTRO INICIAL POR FECHAS ###########################

#Acá cargo todas las transferencias en los hash para después mostrarlas según los filtros
sub makeStatQuery()
{
	opendir(DIR,$transfer);
	my @filesOFTP = readdir(DIR);
	my @workFiles=();
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		print "un archivo $aFile\n";

		if(fileMatchAnioMesFilter($aFile))
		{
			push @workFiles, $aFile;
			print "un archivo $aFile adentro\n";
		}
	}
	foreach(@workFiles)
	{
		my $aFile = $_;
		$workFilePath = $transfer.$aFile;
		open F_WORKFILEPATH, "<", "$workFilePath" or die "No se pudo abrir el archivo de $workFilePath";

		print "$workFilePath\n";
		#Recorro secuencialmente los archivos y cargo los hash
		while(my $line = <F_WORKFILEPATH>)
		{
			print "$line\n";
			chomp;
			($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $line);
			
			if($eOrigen ne $eDestino)
			{
				if(not exists $transferenciasOrigenDestinoHash{$eOrigen})
				{
					$transferenciasOrigenDestinoHash{$eOrigen}{$eDestino}=();
				}
				elsif(not exists $transferenciasOrigenDestinoHash{$eOrigen}{$eDestino})
				{
					$transferenciasOrigenDestinoHash{$eOrigen}{$eDestino}=();
				}

				if(not exists $transferenciasOrigenFechaHash{$eOrigen})
				{
					$transferenciasOrigenFechaHash{$eOrigen}{$fechaTransf}=();
				}
				elsif(not exists $transferenciasOrigenFechaHash{$eOrigen}{$fechaTransf})
				{
					$transferenciasOrigenFechaHash{$eOrigen}{$fechaTransf}=();
				}

				if(not exists $transferenciasDestinoFechaHash{$eDestino})
				{
					$transferenciasDestinoFechaHash{$eDestino}{$fechaTransf}=();
				}
				elsif(not exists $transferenciasDestinoFechaHash{$eDestino}{$fechaTransf})
				{
					$transferenciasDestinoFechaHash{$eDestino}{$fechaTransf}=();
				}

				if(not exists $cbuOrigenDestinoHash{$cbuOrigen})
				{
					$cbuOrigenDestinoHash{$fechaTransf}{$cbuOrigen}=();
				}
				elsif(not exists $cbuOrigenDestinoHash{$cbuOrigen}{$cbuDestino})
				{
					$cbuOrigenDestinoHash{$fechaTransf}{$cbuDestino}=();
				}

				if(not exists $rankingRecibieronHash{$eDestino})
				{
					$rankingRecibieronHash{$eDestino}=0;
				}

				if(not exists $rankingEmitieronHash{$eOrigen})
				{
					$rankingEmitieronHash{$eOrigen}=0;
				}

				push @{$transferenciasOrigenDestinoHash{$eOrigen}{$eDestino}}, $line;
				push @{$transferenciasOrigenFechaHash{$eOrigen}{$fechaTransf}}, $line;
				push @{$transferenciasDestinoFechaHash{$eDestino}{$fechaTransf}}, $line;
				push @{$cbuOrigenHash{$fechaTransf}{$cbuOrigen}}, $line;
				push @{$cbuDestinoHash{$fechaTransf}{$cbuDestino}}, $line;

				$rankingRecibieronHash{$eDestino} = $rankingRecibieronHash{$eDestino} + $importe;
				$rankingEmitieronHash{$eOrigen} = $rankingEmitieronHash{$eOrigen} + $importe;
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
		my $aDate= substr $fileName, 0,8;
		my $anio= substr $aDate, 0,4;
		my $mes = substr $aDate, 4,2;
		my $dia = substr $aDate, 6,2;

		my $rangeAnio= substr $rangeOfaniomes[0], 0,4;
		my $rangeMes = substr $rangeOfaniomes[0], 4,2;
		my $rangeDia = substr $rangeOfaniomes[0], 6,2;
		print "Fecha $aDate\n";
		print "Anio $anio\n";
		print "Mes $mes\n";
		print "dia $dia\n";
		print "RangeAnio $rangeAnio\n";
		print "RangeMes $rangeMes\n\n";

		if($statFilterType ==1)
		{	
			if ($rangeAnio eq $anio and $rangeMes eq $mes and $rangeDia eq $dia)
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
			my $rangeDiaMax = substr $rangeOfaniomes[1], 6,2;
			if ($rangeAnio <= $anio and $rangeMes <= $mes and $rangeDia <= $dia and $anio <= $rangeAnioMax and $mes <= $rangeMesMax and $dia <= $rangeDiaMax)
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
sub blankAllQuerySelection()
{
	$querySelectionChoice = "*";
	$filtroFuentesSelection = "*";
	$filtroEntidadOrigenSelection = "*";
	$filtroEntidadDestinoSelection = "*";
	$filtroEstadoSelection = "*";
	$filtroFechasSelection[0] = "*";
	$filtroImporteMinSelection = "-9999999999";
	$filtroImporteMaxSelection = "99999999";
}




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
			if($typeOfListSelection == 1 or $typeOfListSelection == 2 or $typeOfListSelection ==4)
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
			}
			
			showOutputMenu();
			if($typeOfOutputSelection == 5)
			{
				exit 0;
			}
			elsif($typeOfOutputSelection > 5)
			{
				showErrorSelection();
			}
			elsif($typeOfOutputSelection < 4)
			{
				getQuery();
				showQueryResult();
				blankAllQuerySelection();
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


sub validarFuente
{
	my ($aFuente) = @_;
	if($filtroFuentesSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@fuentesValidadas))
		{
			if($aFuente eq $fuentesValidadas[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
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


sub validarEntidadOrigen
{
	my ($unaEntidadOrigen) = @_;
	if($filtroEntidadOrigenSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@entidadesOrigenValidadas))
		{
			if($unaEntidadOrigen eq $entidadesOrigenValidadas[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
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


sub validarEntidadDestino
{
	my ($unaEntidadDestino) = @_;
	if($filtroEntidadDestinoSelection eq '*')
	{
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@entidadesDestinoValidadas))
		{
			if($unaEntidadDestino eq $entidadesDestinoValidadas[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
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

sub validarEstado
{
	my ($unEstado) = @_;
	#print "#### validar Estado: ".$unEstado."\n";
	#print "##### FiltroEstadSelection: ".$filtroEstadoSelection."\n";
	if($filtroEstadoSelection eq '*')
	{
		#print "Entra porque la selection es * i\n ";
		return 1;
	}
	else
	{
		$encontroMatch = 0;
		$i=0;
		while( $encontroMatch ==0 && $i < scalar(@estadosValidados))
		{
			if($unEstado eq $estadosValidados[$i])
			{
				return 1;
			}
			else
			{
				$i++;
			}
		}
		return 0;
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
	elsif($fechaTransfFilterType == 3)
	{
		@fechasTransfValidados=();
		$filtroFechasSelection[0]="*";
		push @fechasTransfValidados, $filtroFechasSelection[0];
	}

}

sub validarFiltroFecha
{

	if($fechaTransfFilterType ==3)
	{
		return 1;
	}
	else
	{
		my ($unaFechaParaValidar) = @_;
		my $aDate= substr $fileName, 0,8;
		my $anio= substr $aDate, 0,4;
		my $mes = substr $aDate, 4,2;
		my $dia = substr $aDate, 6,2;

		my $rangeAnio= substr $fechasTransfValidados[0], 0,4;
		my $rangeMes = substr $fechasTransfValidados[0], 4,2;
		my $rangeDia = substr $fechasTransfValidados[0], 6,2;
		print "Fecha $aDate\n";
		print "Anio $anio\n";
		print "Mes $mes\n";
		print "dia $dia\n";
		print "RangeAnio $rangeAnio\n";
		print "RangeMes $rangeMes\n\n";

		if($fechaTransfFilterType ==1)
		{	
			if ($rangeAnio eq $anio and $rangeMes eq $mes and $rangeDia eq $dia)
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
			my $rangeAnioMax= substr $fechasTransfValidados[1], 0,4;
			my $rangeMesMax = substr $fechasTransfValidados[1], 4,2;
			my $rangeDiaMax = substr $fechasTransfValidados[1], 6,2;
			if ($rangeAnio <= $anio and $rangeMes <= $mes and $rangeDia <= $dia and $anio <= $rangeAnioMax and $mes <= $rangeMesMax and $dia <= $rangeDiaMax)
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

#Pido información del importe mínimo
sub showImporteFilterMenu()
{
print "\n\tINGRESE EL IMPORTE MINIMO (El mínimo es 0)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($filtroImporteMinSelection = <>);
	
	if($filtroImporteMinSelection =~ /-{0,1}[0-9]/)
	{
		showImporteMaxFilterMenu()
	}
	else
	{
		showErrorSelection();
		$filtroImporteMinSelection = "-9999999999";
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
			$filtroImporteMinSelection = "-99999999";
			$filtroImporteMaxSelection = "99999999";
	}
}


sub validarFiltroImporte
{
	my ($unImporte) = @_;
	#print "Validar filtro importe -> Min: $filtroImporteMinSelection act: $unImporte ->Max: $filtroImporteMaxSelection \n";
	if( $filtroImporteMinSelection <= $unImporte and $unImporte <= $filtroImporteMaxSelection )
	{
		return 1;
	}
	else
	{
		return 0;
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
	if($typeOfListSelection == 1)
	{
		getQueryEntidadesOrigen();
	}
	elsif($typeOfListSelection == 2)
	{
		getQueryEntidadesDestino();
	}
	elsif($typeOfListSelection == 3)
	{
		getQueryBalancePorEntidad();
	}
	elsif($typeOfListSelection == 4)
	{
		getQueryBalanceEntreEntidades();
	}
	elsif($typeOfListSelection == 5)
	{
		getQueryPorCBU();
	}
	elsif($typeOfListSelection == 6)
	{
		showRanking();
	}	
}

sub getQueryEntidadesOrigen()
{
	print "\n\tINGRESE LAS ENTIDADES ORIGEN SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($queryEntidadOrigenSelection = <>);
	@arrayResultQuery=();
	my @entidadesOrigenSel = split(' ',$queryEntidadOrigenSelection);
	@entidadesOrigenAListar=();
	foreach my $unaEntidadOrigen (@entidadesOrigenSel)
	{
		if (exists $transferenciasOrigenFechaHash{$unaEntidadOrigen})
		{
			push @entidadesOrigenAListar, $unaEntidadOrigen;
		}
	}

	foreach my $unaEntidadOrigenAListar (@entidadesOrigenAListar)
	{
		#print "ENTIDAD: $unaEntidadOrigenAListar\n";
		$aLineResult="ENTIDAD: $unaEntidadOrigenAListar\n";
		push @arrayResultQuery, $aLineResult;
		$totalGeneral=0;
		foreach my $unaFechaDeTransferencia (sort keys %{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}})
		{
			#@transferenciasDeUnaFecha =@{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}{$unaFechaDeTransferencia}};
			$subtotalDelDia=0;
			#print "FECHA: $unaFechaDeTransferencia\n";
			$aLineResult="FECHA: $unaFechaDeTransferencia\n";
			push @arrayResultQuery, $aLineResult;
			
			#printf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");
			
			if($typeOfDetailSelection == 1)
			{
				$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");
				push @arrayResultQuery, $aLineResult;
			}
			elsif($typeOfDetailSelection == 2)
			{
				$aLineResult=sprintf("%-15s %-15s\n", "FECHA","IMPORTE");
				push @arrayResultQuery, $aLineResult;
	    	}

	    	foreach my $unaTransferencia (@{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}{$unaFechaDeTransferencia}})
	    	{
		    	($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
		    	if(validarFuente($fuente) and validarEntidadOrigen($eOrigen) and validarEntidadDestino($eDestino) and validarEstado($estado) and validarFiltroFecha($fechaTransf) and validarFiltroImporte($importe))
		    	{
		    		$subtotalDelDia=$subtotalDelDia+$importe;

			    	#printf("%-15s %-15s %-15s %-15s %-15s Subtotal: %-15s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino,$subtotalDelDia);
								
					if($typeOfDetailSelection == 1)
					{
						$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
						push @arrayResultQuery, $aLineResult;
					}
		    	}
			
	    	}
	    	#printf("%-15s %-15s\n\n","subtotal",$subtotalDelDia);
			$aLineResult=sprintf("%-15s %-15s\n\n","subtotal",$subtotalDelDia);
			push @arrayResultQuery, $aLineResult;
	    	$totalGeneral=$totalGeneral+$subtotalDelDia;
		}
		#print "total general $totalGeneral\n\n\n";
		$aLineResult="total general $totalGeneral\n\n\n";
		push @arrayResultQuery, $aLineResult;
	}
}



sub getQueryEntidadesDestino()
{
	print "\n\tINGRESE LAS ENTIDADES DESTINO SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($queryEntidadDestinoSelection = <>);
	@arrayResultQuery=();
	my @entidadesDestinoSel = split(' ',$queryEntidadDestinoSelection);
	@entidadesDestinoAListar=();
	foreach my $unaEntidadDestino (@entidadesDestinoSel)
	{
		if (exists $transferenciasDestinoFechaHash{$unaEntidadDestino})
		{
			push @entidadesDestinoAListar, $unaEntidadDestino;
		}
	}

	foreach my $unaEntidadDestinoAListar (@entidadesDestinoAListar)
	{
		#print "ENTIDAD: $unaEntidadDestinoAListar\n";
		$aLineResult="ENTIDAD: $unaEntidadDestinoAListar\n";
		push @arrayResultQuery, $aLineResult;
		$totalGeneral=0;
		foreach my $unaFechaDeTransferencia (sort keys %{$transferenciasDestinoFechaHash{$unaEntidadDestinoAListar}})
		{
			#@transferenciasDeUnaFecha =@{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}{$unaFechaDeTransferencia}};
			$subtotalDelDia=0;
			#print "FECHA: $unaFechaDeTransferencia\n";
			$aLineResult="FECHA: $unaFechaDeTransferencia\n";
			push @arrayResultQuery, $aLineResult;

			#printf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");

			if($typeOfDetailSelection == 1)
			{
				$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");
				push @arrayResultQuery, $aLineResult;
			}
			elsif($typeOfDetailSelection == 2)
			{
				$aLineResult=sprintf("%-15s %-15s\n", "FECHA","IMPORTE");
				push @arrayResultQuery, $aLineResult;
	    	}

	    	foreach my $unaTransferencia (@{$transferenciasDestinoFechaHash{$unaEntidadDestinoAListar}{$unaFechaDeTransferencia}})
	    	{
		    	($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
		    	#if() VALIDACIONES DE FILTRO
		    	$subtotalDelDia=$subtotalDelDia+$importe;

		    	#printf("%-15s %-15s %-15s %-15s %-15s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
				if($typeOfDetailSelection == 1)
				{
					$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
					push @arrayResultQuery, $aLineResult;
				}	
	    	}
	    	#printf("%-15s %-15s\n\n","subtotal",$subtotalDelDia);
			$aLineResult=sprintf("%-15s %-15s\n\n","subtotal",$subtotalDelDia);
			push @arrayResultQuery, $aLineResult;
	    	$totalGeneral=$totalGeneral+$subtotalDelDia;
		}
		#print "total general $totalGeneral\n\n\n";
		$aLineResult="total general $totalGeneral\n\n\n";
		push @arrayResultQuery, $aLineResult;
	}
}


sub getQueryBalancePorEntidad()
{
	print "\n\tINGRESE LAS ENTIDADES SEPARADAS POR ESPACIOS
	(PARA FILTRAR POR TODAS, INGRESE SOLAMENTE EL CARACTER *)
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($queryBalancePorEntidadSelection = <>);
	@arrayResultQuery=();
	my @entidadesParaBalanceSel = split(' ',$queryBalancePorEntidadSelection);
	@entidadesParaBalanceAListar=();
	foreach my $unaEntidadParaBalance (@entidadesParaBalanceSel)
	{
		push @entidadesParaBalanceAListar, $unaEntidadParaBalance;
	}

	foreach my $unaEntidadParaBalanceAListar (@entidadesParaBalanceAListar)
	{
		#print "ENTIDAD: $unaEntidadParaBalanceAListar\n";
		$aLineResult="ENTIDAD: $unaEntidadParaBalanceAListar\n";
		push @arrayResultQuery, $aLineResult;
		$totalDesde=0;
		foreach my $unaEntidadDestino(sort keys %{$transferenciasOrigenDestinoHash{$unaEntidadParaBalanceAListar}}) 
		{
			$transferenciasDeUnaFecha =$transferenciasOrigenDestinoHash{$unaEntidadParaBalanceAListar}{$unaEntidadDestino};
	    	foreach my $unaTransferencia (@transferenciasDeUnaFecha)
	    	{
		    	($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
		    	#if() VALIDACIONES DE FILTRO
		    	$totalDesde=$totalDesde+$importe;
	    	}
	    	#printf("%-30s %-15s %-15s\n","Desde $codOrigen",$totalDesde,"hacia otras entidades");
	    	$aLineResult=sprintf("%-30s %-15s %-15s\n","Desde $codOrigen",$totalDesde,"hacia otras entidades");
			push @arrayResultQuery, $aLineResult;
		}

		$totalHacia=0;
	    foreach my $unaEntidadOrigen(sort keys %$transferenciasOrigenDestinoHash) 
		{
			foreach my $unaEntidadDestino (keys %{$transferenciasOrigenDestinoHash{$unaEntidadOrigen}}) 
			{
				if($unaEntidadParaBalanceAListar eq $unaEntidadDestino and $unaEntidadParaBalanceAListar ne $unaEntidadOrigen)
				{
					$transferenciasDeUnaFecha =$transferenciasOrigenDestinoHash{$unaEntidadOrigen}{$unaEntidadParaBalanceAListar};
			    	foreach my $unaTransferencia (@transferenciasDeUnaFecha)
			    	{
				    	($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
				    	#if() VALIDACIONES DE FILTRO
				    	$totalHacia=$totalHacia+$importe;
			    	}
			    	#printf("%-30s %-15s %-15s\n","Hacia $codDestino",$totalHacia,"hacia otras entidades");
			    	$aLineResult=sprintf("%-30s %-15s %-15s\n","Hacia $codDestino",$totalHacia,"hacia otras entidades");
					push @arrayResultQuery, $aLineResult;
				}
			}
		}
	
		if($totalGeneral >=0)
		{
			$textoPosNeg ="POSITIVO";
		}
		else
		{
			$textoPosNeg ="NEGATIVO";
		}
		#print "Balance $textoPosNeg para $unaEntidadParaBalanceAListar\n";
		$aLineResult="Balance $textoPosNeg para $unaEntidadParaBalanceAListar\n";
		push @arrayResultQuery, $aLineResult;
	}

}

sub getQueryBalanceEntreEntidades()
{
	print "\n\tINGRESE LAS DOS ENTIDADES SEPARADAS POR ESPACIOS
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($queryEntidadOrigenDestinoSelection = <>);
	@arrayResultQuery=();

	my @entidadesOrigenDestinoSel = split(' ',$queryEntidadOrigenDestinoSelection);
	@entidadesOrigenDestinoAListar=();
	foreach my $unaEntidadParaBalanceConOtra (@entidadesOrigenDestinoSel)
	{
		push @entidadesOrigenDestinoAListar, $unaEntidadParaBalanceConOtra;
	}

	$unaEntidadParaBalancearConOtra = $entidadesOrigenDestinoAListar[0];
	$totalDesdeUnoOtro=0;
	foreach my $unaFechaDeTransferencia (sort keys %{$transferenciasOrigenFechaHash{$unaEntidadParaBalancearConOtra}})
	{
		#@transferenciasDeUnaFecha =@{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}{$unaFechaDeTransferencia}};
		$subtotalDelDia=0;
		if($typeOfDetailSelection == 1)
		{
			$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");
			push @arrayResultQuery, $aLineResult;
		}
		elsif($typeOfDetailSelection == 2)
		{
			$aLineResult=sprintf("%-15s %-15s\n", "FECHA","IMPORTE");
			push @arrayResultQuery, $aLineResult;
    	}
		
    	foreach my $unaTransferencia (@{$transferenciasOrigenFechaHash{$unaEntidadParaBalancearConOtra}{$unaFechaDeTransferencia}})
    	{
	    	($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
	    	#if() VALIDACIONES DE FILTRO
	    	if($eDestino eq $entidadesOrigenDestinoAListar[1] )
	    	{
		    	$subtotalDelDia=$subtotalDelDia+$importe;
		    	#print "$unaTransferencia\n";
		    	#printf("%-15s %-15s %-15s %-15s %-15s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
		    	if($typeOfDetailSelection == 1)
				{
					$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
					push @arrayResultQuery, $aLineResult;
				}
	    	}
		}
    	$totalDesdeUnoOtro=$totalDesdeUnoOtro+$subtotalDelDia;
	}
	#print "Desde $entidadesOrigenDestinoAListar[0] hacia $entidadesOrigenDestinoAListar[1] $totalDesdeUnoOtro\n\n";
	$aLineResult="Desde $entidadesOrigenDestinoAListar[0] hacia $entidadesOrigenDestinoAListar[1] $totalDesdeUnoOtro\n\n";
	push @arrayResultQuery, $aLineResult;

	$otraEntidadParaBalancearConUna = $entidadesOrigenDestinoAListar[1];
	$totalDesdeOtroUno=0;
	foreach my $unaFechaDeTransferencia (sort keys %{$transferenciasOrigenFechaHash{$otraEntidadParaBalancearConUna}})
	{
		#@transferenciasDeUnaFecha =@{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}{$unaFechaDeTransferencia}};
		$subtotalDelDia=0;
		#printf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");

		if($typeOfDetailSelection == 1)
		{
			$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","ORIGEN","DESTINO");
			push @arrayResultQuery, $aLineResult;
		}
		elsif($typeOfDetailSelection == 2)
		{
			$aLineResult=sprintf("%-15s %-15s\n", "FECHA","IMPORTE");
			push @arrayResultQuery, $aLineResult;
    	}

    	foreach my $unaTransferencia (@{$transferenciasOrigenFechaHash{$otraEntidadParaBalancearConUna}{$unaFechaDeTransferencia}})
    	{
	    	($fuente, $eOrigen, $codOrigen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
	    	#if() VALIDACIONES DE FILTRO
	    	if($eDestino eq $entidadesOrigenDestinoAListar[0] )
	    	{
		    	$subtotalDelDia=$subtotalDelDia+$importe;
		    	#print "$unaTransferencia\n";
		    	#printf("%-15s %-15s %-15s %-15s %-15s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
		    	if($typeOfDetailSelection == 1)
				{
					$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
					push @arrayResultQuery, $aLineResult;
				}
	    	}
		}
    	$totalDesdeOtroUno=$totalDesdeOtroUno+$subtotalDelDia;
	}
	#print "Desde $entidadesOrigenDestinoAListar[1] hacia $entidadesOrigenDestinoAListar[0] $totalDesdeOtroUno\n\n";
	$aLineResult="Desde $entidadesOrigenDestinoAListar[1] hacia $entidadesOrigenDestinoAListar[0] $totalDesdeOtroUno\n\n";
	push @arrayResultQuery, $aLineResult;


	$total = $totalDesdeOtroUno - $totalDesdeUnoOtro;
	if($total < 0)
	{
		$resBalance="NEGATIVO";
	}
	else
	{
		$resBalance="POSITIVO";
	}
	#print "Balance $resBalance para $entidadesOrigenDestinoAListar[0] $total\n\n\n";
	$aLineResult="Balance $resBalance para $entidadesOrigenDestinoAListar[0] $total\n\n\n";
	push @arrayResultQuery, $aLineResult;
}


sub getQueryPorCBU()
{
	print "\n\tINGRESE EL NUMERO DE CUENTA CBU
	-----------------------------------------------------------------------\n";
	print "\tSELECCION ";
	chomp($queryCBUSelection = <>);
	@arrayResultQuery=();
	foreach my $unaFechaDeTransferencia (sort keys %cbuOrigenHash)
	{
		#printf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","DESDE","HACIA");
		$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-15s\n", "FECHA","IMPORTE","ESTADO","DESDE","HACIA");
		push @arrayResultQuery, $aLineResult;
		#@transferenciasDeUnaFecha =@{$transferenciasOrigenFechaHash{$unaEntidadOrigenAListar}{$unaFechaDeTransferencia}};
		$subtotalDelDiaOrigen=0;
		if(exists $cbuOrigenHash{$unaFechaDeTransferencia}{$queryCBUSelection})
		{
	    	foreach my $unaTransferencia (@{$cbuOrigenHash{$unaFechaDeTransferencia}{$queryCBUSelection}})
	    	{
		    	($fuente, $eOrigen, $codOrizgen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
		    	#if() VALIDACIONES DE FILTRO
		    	$subtotalDelDiaOrigen=$subtotalDelDiaOrigen+$importe;

		    	#printf("%-15s %-15s %-15s %-15s %-15s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
		    	$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
				push @arrayResultQuery, $aLineResult;

	    	}
	    	#printf("%-15s %-15s\n"," ",$subtotalDelDiaOrigen);
	    	$aLineResult=sprintf("%-15s %-15s\n"," ",$subtotalDelDiaOrigen);
			push @arrayResultQuery, $aLineResul
	    }

		$subtotalDelDiaDestino=0;
		if(exists $cbuDestinoHash{$unaFechaDeTransferencia}{$queryCBUSelection})
		{
	    	foreach my $unaTransferencia (@{$cbuDestinoHash{$unaFechaDeTransferencia}{$queryCBUSelection}})
	    	{
		    	($fuente, $eOrigen, $codOrizgen, $eDestino,$codDestino,$fechaTransf,$importe,$estado,$cbuOrigen,$cbuDestino) = split(";", $unaTransferencia);
		    	#if() VALIDACIONES DE FILTRO
		    	$subtotalDelDiaDestino=$subtotalDelDiaDestino+$importe;
		    	
		    	#printf("%-15s %-15s %-15s %-15s %-15s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
		    	$aLineResult=sprintf("%-15s %-15s %-15s %-15s %-s",$unaFechaDeTransferencia,$importe,$estado,$cbuOrigen,$cbuDestino);
				push @arrayResultQuery, $aLineResult;
	    	}
	    	#printf("%-15s %-15s\n"," ",$subtotalDelDiaDestino);
			$aLineResult=sprintf("%-15s %-15s\n"," ",$subtotalDelDiaDestino);
			push @arrayResultQuery, $aLineResult;

		}

		if(exists $cbuOrigenHash{$unaFechaDeTransferencia}{$queryCBUSelection} or exists $cbuDestinoHash{$unaFechaDeTransferencia}{$queryCBUSelection})
		{
			$totalDelDia=$subtotalDelDiaDestino-$subtotalDelDiaOrigen;
			if($totalDelDia >=0)
			{
				$textoPosNeg ="POSITIVO";
			}
			else
			{
				$textoPosNeg ="NEGATIVO";
			}
			#printf("%-15s %-15s %-15s %-15s\n","Balance $textoPosNeg",$totalDelDia,"para la cuenta",$queryCBUSelection);
			$aLineResult=sprintf("%-15s %-15s %-15s %-15s\n","Balance $textoPosNeg",$totalDelDia,"para la cuenta",$queryCBUSelection);
			push @arrayResultQuery, $aLineResult;
		}
	}
}


sub showRanking()
{
	@arrayResultQuery=();
	my $i=0;
	#sprintf("%-5s %-15s %-30s\n", "N","ENTIDAD","IMPORTE TOTAL RECIBIDO");
	$aLineResult=sprintf("%-5s %-15s %-30s\n", "N","ENTIDAD","IMPORTE TOTAL RECIBIDO");
	push @arrayResultQuery, $aLineResult;
	foreach my $eDestino (sort { $rankingRecibieronHash{$b} <=> $rankingRecibieronHash{$a} } keys %rankingRecibieronHash) 
	{
	    #printf "%-5s %-15s %-30s\n",$i+1,$eDestino, $rankingRecibieronHash{$eDestino};
	    $aLineResult=sprintf "%-5s %-15s %-30s\n",$i+1,$eDestino, $rankingRecibieronHash{$eDestino};
		push @arrayResultQuery, $aLineResult;
	    last if ($i++ == 2);   
	}

	$i=0;
	#printf("%-5s %-15s %-30s\n", "N","ENTIDAD","IMPORTE TOTAL EMITIDO");
	$aLineResult=sprintf("%-5s %-15s %-30s\n", "N","ENTIDAD","IMPORTE TOTAL EMITIDO");
	push @arrayResultQuery, $aLineResult;
	foreach my $eOrigen (sort { $rankingEmitieronHash{$b} <=> $rankingEmitieronHash{$a} } keys %rankingEmitieronHash) 
	{
	    #printf "%-5s %-15s %-30s\n",$i+1,$eOrigen, $rankingEmitieronHash{$eOrigen};
	    $aLineResult=sprintf "%-5s %-15s %-30s\n",$i+1,$eOrigen, $rankingEmitieronHash{$eOrigen};
		push @arrayResultQuery, $aLineResult;
	    last if ($i++ == 2);
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
			unless(-e $listadosDir)
			{
			`mkdir -p $listadosDir`;
			}

			$filename = $listadosDir."unListado.".getNextListadoID();	
		}
		elsif($typeOfListSelection == 3 or $typeOfListSelection == 4)
		{
			unless(-e $balancesDir)
			{
			`mkdir -p $balancesDir`;
			}
			$filename = $balancesDir."unBalance.".getNextBalanceID();	
		}
		elsif($typeOfListSelection == 6)
		{
			unless(-e $rankingDir)
			{
			`mkdir -p $rankingDir`;
			}
			$filename = $rankingDir."unRanking.".getNextRankingID();
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



##############################################################
########################## UTILS ############################

#Devuelve el numero siguiente al número mayor del nombre de los archivos de listados creados.
sub getNextListadoID()
{
	$lastId =0;
	my $cantArchivos=0;
	my @workFilesListado=();
	opendir(DIR,$listadosDir);
	my @filesOFTP = readdir(DIR);
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		if(length($aFile) >= 10)
		{
			$nombreListado = substr $file, 0, 9;
			$nombrePunto = substr $file, 9,1;
			if( $nombreListado == "unListado" and nombrePunto == ".")
			{
				push @workFilesListado, $aFile;
				$cantArchivos=$cantArchivos+1;		
			}
		}
	}
	if ( $cantArchivos >0)
	{
		if( $cantArchivos -10 >= 0)
		{
			$lastId = "0".($cantArchivos);
		}
		elsif( $cantArchivos -100 >= 0)
		{
			$lastId = $cantArchivos;
		}
		else
		{
			$lastId = "00".($cantArchivos);
		}
	}
	else
	{
		$lastId = "000";
	}
	return $lastId;
}

#Devuelve el numero siguiente al número mayor del nombre de los archivos de balance creados.
sub getNextBalanceID()
{
	$lastId =0;
	my $cantArchivos=0;
	my @workFilesBalance=();
	opendir(DIR,$balancesDir);
	my @filesOFTP = readdir(DIR);
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		if(length($aFile) >= 10)
		{
			$nombreBalance = substr $file, 0, 9;
			$nombrePunto = substr $file, 9,1;
			if( $nombreBalance == "unBalance" and nombrePunto == ".")
			{
				push @workFilesBalance, $aFile;
				$cantArchivos=$cantArchivos+1;		
			}
		}
	}
	if ( $cantArchivos >0)
	{
		if( $cantArchivos -10 >= 0)
		{
			$lastId = "0".($cantArchivos);
		}
		elsif( $cantArchivos -100 >= 0)
		{
			$lastId = $cantArchivos;
		}
		else
		{
			$lastId = "00".($cantArchivos);
		}
	}
	else
	{
		$lastId = "000";
	}
	return $lastId;
}

#Devuelve el numero siguiente al número mayor del nombre de los archivos de ranking creados.
sub getNextRankingID()
{
	$lastId =0;
	my $cantArchivos=0;
	my @workFilesRanking=();
	opendir(DIR,$balancesDir);
	my @filesOFTP = readdir(DIR);
	closedir(DIR);
	foreach(@filesOFTP)
	{
		my $aFile = $_;
		if(length($aFile) >= 10)
		{
			$nombreRanking = substr $file, 0, 9;
			$nombrePunto = substr $file, 9,1;
			if( $nombreRanking == "unRanking" and nombrePunto == ".")
			{
				push @workFilesRanking, $aFile;
				$cantArchivos=$cantArchivos+1;		
			}
		}
	}
	if ( $cantArchivos >0)
	{
		if( $cantArchivos -10 >= 0)
		{
			$lastId = "0".($cantArchivos);
		}
		elsif( $cantArchivos -100 >= 0)
		{
			$lastId = $cantArchivos;
		}
		else
		{
			$lastId = "00".($cantArchivos);
		}
	}
	else
	{
		$lastId = "000";
	}
	return $lastId;
}



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
# Usage:	TRANSFERLIST.pl -<c|h>
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
