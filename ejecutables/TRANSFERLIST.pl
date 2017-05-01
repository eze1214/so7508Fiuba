#!/usr/bin/perl 
use Getopt::Long;
use Scalar::Util qw(looks_like_number);


#Hashes
%transferenciasOrigenDestinoHash;
%cbuDesdeHash;
%cbuHastaHash;
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
$filtroImporteMaxSelection = "99999";


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

sub showQuerySelection()
{
print "\n\tSELECCION DE CONSULTA
	-----------------------------------------------------------------------
	1) Filtro por fuente (una, varias, todas)
	2) Filtro por Entidad origen (una, varias, todas)
	3) Filtro por Entidad destino (uno, varias, todas)
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
		showFechTransfFilterMenu();
	}
	elsif($querySelectionChoice == 6)
	{
		showImporteFilterMenu();
	}
	elsif($querySelectionChoice == 7)
	{
		getQuery();
		showQueryResult();
		mainQuery();
	}
	else
	{
		exit 0;
	}		

	showQuerySelection();

}



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
		while(<F_WORKFILEPATH>)
		{
			##TODO Lun 1/5
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



#Valido que la fecha sea del tipo AAAAMMDD
sub validateDateFormat()
{
	my ($aDate) = @_;

	if(length($aDate) != 6)
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

	if($anio >2015 or $mes > 12 or $mes <1 or $dia > 31 or $dia < 1)
	{
		return 0;
	}
	
	return 1;
	
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