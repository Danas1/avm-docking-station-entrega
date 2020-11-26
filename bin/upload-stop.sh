#!/bin/bash

PIPEUP="/home/pi/pipes/pipeup"
#Borra el pipe creado por el servicio de subida.
if [ -p $PIPEUP ]; then
	rm $PIPEUP
fi
systemctl exit upload-server.service
exit 0

