#!/bin/bash

##
#Determina si existe un celular conectado
#al docking station.

dev_connected="/bin/dev_connect.txt"

if [ -e "$dev_connected" ]; then
	sudo systemctl start bluetooth-com.service
exit 0
