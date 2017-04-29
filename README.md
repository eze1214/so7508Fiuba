
## Descompresión ## 
Se debe descomprimir el paquete utilizando:
```sh
gunzip instalador.tar.gz tar -xvf instalador.tar
```
## Instalación ##
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
./inicializar.sh
```
El comando se encuentra en el directorio que haya definido para contener los **ejecutables** durente la instalación.
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
