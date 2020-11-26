#!/usr/bin/python3

import serial
import subprocess
import re
import sys
from subprocess import Popen

ser = serial.Serial('/dev/rfcomm0',9600)
wpa_supplicant_path="/etc/wpa_supplicant/wpa_supplicant.conf"
timer_path="/etc/systemd/system/upload-server.timer"
timer_stop_path="/etc/systemd/system/stop-upload.timer"

while True:
        #Opciones para el usuario
        ser.write(b'Enviar numero segun la opcion deseada\n')
        ser.write(b'0: Nada \n')
        ser.write(b'1: Conectar Wifi\n')
        ser.write(b'2: Establecer horarios de subida de datos\n')
        received = ser.readline().rstrip()
        #Ver si se recibio algun mensaje de los otros procesos
        if received == b'0':
            ser.write(b'...\n')
        elif received == b'1':
            #Se realiza el escaneo de las redes wifi y se agregan 
            #a una lista para ser mostradas.
            p = Popen(["sudo", "iwlist", "wlan0","scan"],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
            output, errors = p.communicate()
            output=output.decode()
            output_array=output.split('ESSID:')
            ESSID_LIST = []#Lista donde se agregan las redes wifi disponibles.
            for i in output_array:
                name, resto = i.split("\n",maxsplit=1)
                ESSID_LIST.append(name)
            ser.write(b'Seleccione red eligiendo numero correspondiente\n')
            #Se envian las distintas redes disponibles.
            for i in range(1,len(ESSID_LIST)):
                ser.write(str(i).encode())
                ser.write(b':')
                ser.write(ESSID_LIST[i].encode())
                ser.write(b'\n')
            #Se lee la red elegida por el usuario
            selected_network=ser.readline().rstrip()
            #Falta verificar que la red se encuentre dentro de las disponibles.

            selected_network=int(selected_network)
            # Pedir contrasennai
            ser.write(b'Entregue la contrasenna de la red\n')
            password=ser.readline().rstrip().lstrip()

            selected_ESSID= ESSID_LIST[selected_network].replace('"', '')
            wpa_conf=Popen(["wpa_passphrase", selected_ESSID, password],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
            output, errors = wpa_conf.communicate()
            output=output.decode()
            #Se abre el archivo con las redes wifi y se escribe en este.
            wpa_supplicant=open(wpa_supplicant_path, 'a')
            wpa_supplicant.write(output)
            wpa_supplicant.close()
            ser.write(b'\n')
        elif received == b'2':
            ser.write(b'A que hora desea comenzar a subir la informacion?\n')
            ser.write(b'Formato 24 hrs(0 - 23):' )
            up_time=ser.readline().rstrip().lstrip()
            up_time=up_time.decode()
            #Abrir archivo del timer
            timer_serv=open(timer_path, 'r+')
            timer_serv_lines=timer_serv.readlines()
            onCal_line=0
            for i in range(len(timer_serv_lines)):
                if "OnCalendar" in timer_serv_lines[i]:
                    onCal_line=i
            timer_serv_lines[onCal_line]='OnCalendar=*-*-* ' + up_time + '\n'
            
            timer_serv=open(timer_path, 'w')
            timer_serv.writelines(timer_serv_lines)
            timer_serv.close()
            
            ser.write(b'A que hora desea detener la subida de datos?\n')
            ser.write(b'Formato 24 hrs(0 - 23):')
            stop_time=ser.readline().rstrip().lstrip()
            stop_time=stop_time.decode()
            stop_timer_serv=open(timer_stop_path, 'r+')
            stop_timer_serv_lines=stop_timer_serv.readlines()
            onCal_line=0
            for i in range(len(stop_timer_serv_lines)):
                if "OnCalendar" in stop_timer_serv_lines[i]:
                    onCal_line=i
            stop_timer_serv_lines[onCal_line]='OnCalendar=*-*-* ' + stop_time + '\n'
            stop_timer_serv=open(timer_stop_path, 'w')
            stop_timer_serv.writelines(stop_timer_serv_lines)
            stop_timer_serv.close()
            
            reload_serv=Popen(["sudo","systemctl", "daemon-reload"])
        else :
            ser.write(b'Otra cosa\n') 
