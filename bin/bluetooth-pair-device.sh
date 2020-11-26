#!/usr/bin/expect -f
##
#Identifica cuando se esta esperando un comando. 
set prompt "#"
# Identifica una direccion MAC en el texto.
set MAC_ADDRS_IDENTIFIER "(\[0-9A-F]{2}\[:-]){5}(\[0-9A-F]{2})"
# Indica el tiempo en segundos que espera el programa 
# para salir.
set timeout 120


spawn sudo bluetoothctl
sleep 3
# Espera a que el programa pida un comando.       
expect -re $prompt
#Tanto "power on", como "agent on" deberian estar habilitados
#desde el inicio. Se realiza el chequeo de cualquier forma.
# Habilita el controlador
send "power on\r"
expect {
	"succeeded\r" 	{ send "agent on\r"}
	timeout 	{ puts "timed out during powering\n"; exit 1}
}
# Si el comando "agent on" se ejecuta de manera satisfactoria
# permite que el dispositivo sea visible desde otros 
# dispositivos
expect {
	"registered" 	{ send "discoverable on\r" }
	"succeded\r"	{ send "discoverable on\r" }
 	timeout 	{ puts "timed out enabling agent\n" ; exit 2}
# Si esto se ejecuta correctamente, se envia "pairable on" que
# que permite que se pueda parear con otros dispositivos.
}
expect {
	"succeeded\r"	{ send "pairable on\r" }
	timeout		{ puts "failed during pair\n" ; exit 3}
}
# Se entra cuando un dispositivo ha sido pareado para realizar una 
# conexion. Se espera que este sea el celular del usuario del AVM.
expect {
	"Paired: yes"	{ 
		expect -re $prompt 
		#Busca los dispositivos pareados.
       	send "paired-devices\r"
       	#Identifica la direccion MAC de estos dispositivos.
		expect -re $MAC_ADDRS_IDENTIFIER
		#Guarda la direccion MAC del dispositivo pareado en una variable.
		set MAC_ADDR "$expect_out(0,string)"
		expect -re $prompt
		#Permite que el dispositivo pareado tambien sea un dispositivo
		#confiado
		send "trust $MAC_ADDR\r"
	       		}
	timeout		{ puts "failed pairing devices\n" ; exit 4}
}
#Envia al std_out la direccion MAC del dispositivo recian pareado.
#Esto permite que sea usado fuera del programa.
expect -re $prompt
#Envia mensaje al usuario que el dispositivo fue pareado correctamente.
puts "Device paired correctly\n"
#"pairable off" y "discoverable off" hacen que el dispositivo vuelva
# a ser invisible.
send "pairable off\r"
expect -re $prompt
send "discoverable off\r"
expect -re $prompt
#Termina la sesion de "bluetoothctl"
send "exit\r"
exit 0
