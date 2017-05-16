
# Descompresión
Se debe descomprimir el paquete utilizando:
```sh
gunzip instalador.tar.gz tar -xvf instalador.tar
```
# Instalación
Se debe ejecutar dentro del directorio creado por la descompresión del paquete el script
```sh
./instalar.sh -i
```
y el producto se instala en /home/grupo5

Durante la instalación se pide especificar los directorios, si uno no coloca ningún nombre se ingresa por defecto los siguientes nombres para los directorios

 - TBINARIOS:/home/$USER/grupo05/ejecutables  
 - MAESTROS:/home/$USER/grupo05/maestros
 - NOVEDADES:/home/$USER/grupo05/novedades
 - ACEPTADOS:/home/$USER/grupo05/aceptados/rechazados
 - VALIDADOS:/home/$USER/grupo05/validados
 - REPORTES:/home/$USER/grupo05/reportes LOG:/home/$USER/grupo05/log
 - CONFDIR:/home/$USER/grupo05/dirconf

El sistema no permite nombres repetidos.
> CONFDIR es fijo del sistema y contiene el log del la instalación en el archivo
log.txt y el archivo de configuración config.cnf

## Reinstalación ##
El sistema permite reinstalaciones. Solamente vuelve a instalar los archivos maestros y ejecutables. Se debe ejecutar
```sh
./instalar.sh -i
```
### Detectar instalación ##

```sh
./instalar -t
```
Al ejecutar el comando se verifica si está instalado en el sistema la aplicación En caso afirmativo muestra por pantalla el archivo de configuración

### Verificarla versión de Perl ###
```sh
./instalar.sh -p
```
Ya que parte del sistema necesita Perl para funcionar se incluye un script para verificar que versión de Perl está instalada en el sistema.

# Inicializar Sistema
```sh
. /inicializar.sh
```
> Nota: es importante mantener el espacio entre "." y "/" para lograr el funionamiento óptimo

El comando se encuentra en el directorio que haya definido para contener los **ejecutables** durante la instalación.
Este setea las variables de ambiente definidas en el *Archivo de Configuración* .
Consulta al usuario la posibilidad de ejecutar el *Demonio*

### Parámetros
##### Ejecución automática del Demonio
```sh
./inicializar.sh -d
```
Este parámetro setea las variables de entorno para esa terminal según el **Archivo de Configuración** e inicia automáticamente el demonio.

##### Ayuda #####
```sh
./inicializar.sh -h
```
Muestra las formas de ejecución de *inicializar.sh* y las opciones de parámetros, como se muestra a continuación:
```sh
Uso: inicializar.sh [OPCION..]
            OPCIONES:
                -d          Iniciar el demonio en forma automática
                -h          Muestra Ayuda

            Administrar ejecución de Demonio:
            startd.sh       Iniciar demonio (si aún no lo hace)
            stopd.sh        Detener demonio
```

# Consultas y emisión de listados en Perl

```sh
./TRANSFERLIST.pl
```
El comando se encuentra en el directorio que haya definido para contener los **ejecutables** durante la instalación.
Permite la realización de *consultas* y emitir *reportes*, tanto a pantalla o archivos, sobre los resultados obtenidos del procesamiento de los datos.

## Parámetros
#### Ayuda
```sh
./TRANSFERLIST.pl -h
```
Muestra las formas de ejecución de *TRANSFERLIST.sh* y las opciones de parámetros, como se muestra a continuación:
```sh
Programa: TRANSFERLIST.pl - Grupo 5 - GNU GPLv3
Descripcion: Genera reportes y rankings de transferencias entre entidades
con la aplicación de distintos filtros.  
USAGE: TRANSFERLIST.pl -<h|c>
-----------------------------------------------------------------------

-h : Imprime esta ayuda
-c : Realiza consulta sobre transferencias aplicando filtros
-----------------------------------------------------------------------

Ejemplo:
TRANSFERLIST.pl -h
TRANSFERLIST.pl -c
```

#### Consultas sobre transferencias
```sh
./TRANSFERLIST.pl -c
```
El anterior es el comando necesario para el ingreso a las consultas.

## Funcionalidad

#### Filtro de Fecha
Una vez ingresado al sistema con el comando **-c** el sistema consultará sobre que fechas va a querer consultar, pudiendo hacerlo puntual sobre un día, sobre un rango o sobre todos los existentes.
En todos los casos el formato de ingreso de fecha es AAAAMMDD.
```sh
TIPO DE FILTRO
-----------------------------------------------------------------------
1) Una fecha
2) Un rango de fechas
3) Todas las fechas
-----------------------------------------------------------------------
SELECCION
```
#### Filtros a Aplicar
```sh
SELECCION DE CONSULTA
-----------------------------------------------------------------------
1) Filtro por fuente (una, varias, todas)
2) Filtro por Entidad origen (una, varias, todas)
3) Filtro por Entidad destino (una, varias, todas)
4) Filtro por Estado (uno o ambos)
5) Filtro por fecha de la transferencia (una, rango de fechas)
6) Filtro por importe (entre valor x – valor y)
7) Realizar Consulta
8) Salir
-----------------------------------------------------------------------
SELECCION
```
Sobre el universo de fechas seleccionadas se podrá aplicar distintos filtros para poder refinar el informe deseado. Las opciones 1 a 6 contienen las distintas posibilidades de filtro, una vez finalizado el refinamiento es necesario ingresar *la opción 7 (Realizar Consulta)* para realizar la consulta en sí.


###### Realizar Consulta
Ingresando a la opción 7 del menú *"SELECCIÓN DE CONSULTA"* obtendremos el menú que sigue a continuación. Este nos permite seleccionar el tipo de Listado que queremos generar, sobre el universo de fechas seleccionados, aplicando los filtros aplicados antes.
>Las opciones 7 y 8 tienen como utilidad ir un paso atras en el menú y Salir de la consulta respectivamente.

```sh
SELECCIONAR LISTADO
-----------------------------------------------------------------------
1) Listado por entidades origen
2) Listado por entidades destino
3) Balance por entidad
4) Balance entre dos entidades
5) Listado por CBU
6) Ranking de entidades
7) Volver al menú de filtro
8) Salir
-----------------------------------------------------------------------
SELECCION  
```

Luego de seleccionado alguno de los listados o el ranking el sistema pedirá la forma de salida del listado, *por pantalla*, *en archivo* o *ambos*.
```sh
OPCIONES DE LISTADO
-----------------------------------------------------------------------
1) Por pantalla
2) Por archivo
3) Por pantalla y archivo
4) Volver al menú de selección de filtro
5) Salir
-----------------------------------------------------------------------
SELECCION
```
