#!/usr/bin/python3

import serial
import time
import os


pipe_comm="/home/pi/pipes/pipecomm"
ser = serial.Serial('/dev/rfcomm0',9600)
#Limpia el pipe si existe
if os.path.exists(pipe_comm):
    os.remove(pipe_comm)
#Lo crea nuevamente
try:
    os.mkfifo(pipe_comm)
except OSError as oe:
    if oe.errno != errno.EEXIST:
        raise


with open(pipe_comm) as pipe_fifo:
    while os.path.exists('/dev/rfcomm0'):
        data = pipe_fifo.read()
        if len(data) != 0:
            data = data.strip()
            if data == 'start_backup' :
                ser.write(b'Transfiriendo archivos AVM->Docking Station\n')
            elif data == 'end_backup' :
                ser.write(b'Transferencia AVM->Docking Station terminada\n')
            elif data == 'start_upload' :
                ser.write(b'Subiendo archivos al servidor\n')
            elif data == 'end_upload' :
                ser.write(b'Archivos subidos al servidor\n')
            else :
                ser.write(b'Holiwis\n') 
#Elimina el pipe luego de terminar
if os.path.exists(pipe_comm):
    os.remove(pipe_comm)
    print("pipe removed")
exit(0)
