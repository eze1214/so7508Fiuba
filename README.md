# so7508Fiuba

#Descompresión
Se debe descomprimir el paquete utilizando
gunzip instalador.tar.gz
tar -xvf instalador.tar

#Instalación
Se debe ejecutar dentro del directorio creado por la descompresión del paquete el script ./instalar.sh -i y el producto se instala en /home/grupo5

Durante la instalación se pide especificar los directorios, si uno no coloca ningún nombre se ingresa por defecto los siguientes nombres para los directorios

BINARIOS:/home/$USER/grupo05/ejecutables
MAESTROS:/home/$USER/grupo05/maestros
NOVEDADES:/home/$USER/grupo05/novedades
ACEPTADOS:/home/$USER/grupo05/aceptados/rechazados
VALIDADOS:/home/$USER/grupo05/validados
REPORTES:/home/$USER/grupo05/reportes
LOG:/home/$USER/grupo05/log
CONFDIR:/home/$USER/grupo05/dirconf

El sistema no permite nombres repetidos.

CONFDIR es fijo del sistema y contiene el log del la instalación en el archivo log.txt y el archivo de configuración config.cnf

#Reinstalación
El sistema permite reinstalaciones. Solamente vuelve a instalar los archivos maestros y ejecutables.
Se debe ejecutar ./instalar.sh -i

#Detectar instalación
Al ejecutar ./instalar -t se verifica si está instalado en el sistema la aplicación
En caso afirmativo muestra por pantalla el archivo de configuración

#Verificar la versión de Perl
Ya que parte del sistema necesita Perl para funcionar se incluye un script para verificar que versión de Perl está instalada en el sistema
./instalar.sh -p

#Ejecución
Se debe ejecutar en el directorio de ejectutables el script grupo5.sh y automáticamente comienza a funcionar el sistema. 
El mismo tiene un daemon que va monitoreando las actualizaciones que se encuentran en el directorio de novedades.

