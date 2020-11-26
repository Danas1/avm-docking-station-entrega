# Prototipo AVM Docking Station
Este proyecto busca desarrollar un prototipo funcional que permita copiar  y respaldar la informacion proveniente de un AVM,
ser configurable a tráves del celular de un usuario y transferir los archivos descargados del AVM hacia un servidor externo.
***
##  Tecnologias

Todo lo aqui descrito esta probado utilizando una Raspberry pi 3B, con SO Raspbian Lite.
Adicionalmente se instalaron las herramientas
* rsync: Version 3.1.3
* expect: Version *
* Python: Version 3.6
* GPIOZero (libreria de python)
* serial (libreria de python)
* system (libreria de python)
* Bluez
* Systemd: version


Ademas para probar la conexion con el celular, se descargo de Play Store, la aplicacion Serial Bluetooth Terminal.


## Instalacion

### Configuracion Rasperry Pi
Para realizar la instalacion, es necesario contar con permisos de administrador, ademas de una conexion ssh con la RPI.
En el caso de una RPI, el usuario por defecto 'pi' cuenta con estos permisos. 

Se debe copiar los archivos en /bin y /etc a sus carpetas correspondientes en la RPI, y luego ejecutar el script install.sh, 
que reiniciara las reglas udev, habilitara todos los servicios en /etc/systemd/system, y hara ejecutables todos los scripts en /bin.

```
udevadm control --reload-rules && udevadm trigger

for file in /bin/systemd/system/ :dsadsadasas 
```

Adicionalmente, es necesario configurar el cliente ssh que se encuentra en el archivo '/etc/ssh_config' para que utilice los mismos protocolos que el servidor. 
El ultimo paso es generar una llave correspondiente a alguno de estos protocolos (por ejemplo rsa) y copiarla al servidor mediante los siguientes comandos
```
ssh-keygen rsa
ssh-copy-id user@server_ip
```
> Este proceso permite conectarnos sin necesidad de contraseña al servidor, aunque al ejecutarse la primera vez pedira la contraseña del servidor . 

Finalmente se debe copiar la llave publica del servidor al archivo '/etc/known_host'. De esta forma es posible conocer que 
nos estamos conectando al servidor y no a un tercero.
### Configuracion servidor

Para recibir los archivos es necesario que el servidor cuente con la herramienta rsync. Como en este caso se utilizo CentOS 7, 
para instalar esta se utiliza el siguiente comando
```
yum install rsync
```
Ademas es necesario configurar el archivo '/etc/sshd_config' para que permita los mismos protocolos que la RPI ademas de 
permitir conexiones a traves de pares de llaves.
Finalmente, se debe 

### Comentarios adicionales
El proceso anteriormente descrito debe ser automatizado para que la llave publica del servidor se encuentre previamente en el 
Docking Station antes de ser lanzado por primera vez. De otra forma la RPI requiere una interaccion mediante consola para conectarse al servidor por lo que los datos no podran ser subidos a este ultimo.

## Bugs y problemas conocidos
En esta seccion se detallan diversos problemas conocidos que existen en este proyecto.
***
### Comunicacion Bluetooth
#### Conexion no segura
El intercambio de mensajes entre la RPI y el telefono del usuario, se da a traves de un canal de comunicacion serial en que los 
mensajes no son  encriptados, lo que convierte esto en una posible vulnerabilidad.

#### Pareo con celular
La RPI, solo admite parear un celular a la vez, una vez que esta conexion esta hecha no es posible eliminarla sin entrar a la consola y entregar los siguientes comandos 
```
sudo bluetoothctl
[bluetoothctl] remove MAC_ADDR
# MAC_ADDR: Direccion MAC del celular, apretando Tab se completa automaticamente.
```
#### Establecimiento de horarios
El establecimiento de horarios debe realizarse con el formato correcto, ya que no se cuenta con forma de chequear que se estan entregando valores validos.
***
### Conexion entre AVM y Docking Station.
#### Vulnerabilidad al identificar dispositivo
Debido a que no se cuenta con un AVM, la RPI esta configurada para detectar cualquier tipo de dispositivo de almacenamiento USB. 
Por lo que actualmente cualquier dispositivo de almacenamiento puede descargar archivos a la RPI.
***
## Trabajos por realizar
A continuacion se listaran dos trabajos que podrian ayudar a mejorar el funcionamiento del dispositivo.
#### Automatizar instalacion de SO y modificar este.
Actualmente es necesario utilizar la consola de la RPI para realizar el proceso de intercambio de llaves entre servidor y RPI, 
lo que hace que no sea posible entregar al usuario directamente y requiere un paso adicional. 
Ademas se puede eliminar del SO las herramientas que no sean necesarias.

#### Mejorar conexion con usuario.
Debido a que no se cuenta con una aplicacion para celular se utilizo una forma sencilla para realizar esta comunicacion. 
Desarrollando alguna aplicacion que permita comunicarse utilizando tecnologias como MQTT o Google Cloud Messaging (GCM) 
podria mejorar de gran manera la experiencia del usuario.
