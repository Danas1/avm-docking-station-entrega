#!/bin/bash
AVMDIR="/mnt/AVM" #Directorio usado para montar AVM
BACKUPDIR="/home/pi/backups/" #Directorio usado para guardar los respaldos.
LOGDIR="/home/pi/dockingstation.log"
PIPECOMM="/home/pi/pipes/pipecomm"
PIPEUP="/home/pi/pipes/pipeup"
#SETUP PREVIO


#Checkear si existe el directorio donde el AVM sera montado.
if [ ! -d $AVMDIR ]; then
	#Crea el directorio si no existe previamente
	mkdir $AVMDIR
fi

#Checkear si existe el directorio donde se guardara la informacion.
if [ ! -d $BACKUPDIR ]; then
	mkdir $BACKUPDIR
fi

sleep 5


#########
#Aca empieza la funcionalidad
#######

mount -v /dev/avm_link $AVMDIR
#Verificar que el dispositivo se monto correctamente.
if [ $? -eq 0 ]; then 
	#Cuando el dispositivo fue montado correctamente.
	echo "$(date +"%Y/%m/%d %T") AVM conectado" >> $LOGDIR
	#Enviar mensaje al usuario que los archivos se comenzaran a subir si se encuentra conectado.
	if [ -p $PIPECOMM ]; then
		echo 'start_backup' > $PIPECOMM
	fi
else
	echo "AVM no fue conectado de forma correcta"
	#exit 1
fi

#agregar --remove-source-files para eliminar archivos del pendrive.0
rsync -Pra --out-format="%t %n" --include=AVM* --exclude=* "$AVMDIR/" $BACKUPDIR  \
	| grep -B 1 -e "100%" \
	| grep "AVM*" \
	| sed -e "s+AVM+ Transferencia AVM->Docking Station AVM+"  \
	>> $LOGDIR
#Opciones RSYNC
#-P: Otorga informacion del progreso de los archivos (util para debugear.
#-r: Busca recursivamente en los directrios del directorio fuente (AVMDIR)
#-a: Modo archivo, mantiene los permisos del archivo transferido.
#-vv: Agrega informacion a la salida, util para debugear.
#--remove-source-files: Elimina los archivos de la fuente una vez que estos se transfirieron de forma exitosa.
#--include=AVM* --exclude=*: Solo incluye los archivos que su nombre comienze por AVM.
###
#grep
# -B 1 : Entrega una linea antes, esto para conocer que archivos se completo la transferencia.
# grep "AVM" entrega el nombre del archivo
#sed reemplaza el nombre del archivo 
umount $AVMDIR
#Enviar mensaje al usuario que los archivos ya fueron transferidos si esta conectado.
systemctl is-active --quiet bluetooth-comm.service
if [ -p $PIPECOMM ]; then
	echo "end_backup" > $PIPECOMM
fi

#Enviar mensaje al proceso encargado de subir archivos si se encuentra activo.
if [ -p $PIPEUP ]; then
	echo 'upload_files' > $PIPEUP
fi

exit 0
