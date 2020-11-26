#!/bin/bash

SERV_IP_ADDR="asdf@192.168.1.25:backup/"
#asdf es un usuario en el servidor.
SOURCE_DIR="/home/pi/backups/"
LOGDIR="/home/pi/dockingstation.log"
PIPECOMM="/home/pi/pipes/pipecomm"
PIPEUP="/home/pi/pipes/pipeup"

upload_files() {
	send_comm_start
	rsync -Pa --out-format="%t %n" -e ssh $SOURCE_DIR $SERV_IP_ADDR  \
		| grep -B 1 -e "100%"  \
		| grep "AVM*" \
		| sed -e "s+AVM+ Transferencia Docking Station->servidor AVM+"  \
		>> $LOGDIR
	#-P: Permite reanudar transferencias parciales
	#=a: Archivos mantienen los permisos
	#--vv: Entrega mayor informacion
	#i : --output-format== %i %n %di
	send_comm_end
}

send_comm_start() {
#Envia al celular que se comenzo la subida de datos al servidor
	if [ -p $PIPECOMM ]; then
		sudo bash -c "echo 'start_upload' > '$PIPECOMM'"
	fi
}


send_comm_end() {
	if [ -p $PIPECOMM ]; then
		sudo bash -c "echo 'end_upload' > '$PIPECOMM'"
	fi	
}

make_pipeup() {
	#Crea un pipe vacio para comunicarse con este proceso.
	if [ ! -p $PIPEUP ]; then
		sudo mkfifo $PIPEUP
	fi	
}

wait_for_upload() {
	#Espera una sennal para realizar la subida de datos
	if [ -p $PIPEUP ]; then
		while true
		do
			if read line < $PIPEUP; then
				if [ $line == 'upload_files' ]; then
					upload_files
				fi
			fi
		done
	fi
}
main() {
	make_pipeup
	#Realiza la subida de archivos la primera vez que es invocada
	upload_files
	wait_for_upload

}

main
exit 0
