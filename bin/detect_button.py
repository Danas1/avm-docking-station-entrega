#!/usr/bin/python3
from gpiozero import Button
from time import sleep
import os

pair_script="/bin/bluetooth-pair-device.sh"
remove_dev="/bin/bluetooth-remove-device.sh"
button = Button(4)
count = 0
while True:
    sleep(0.5)
    if(button.is_pressed):
        count = count + 1
    else:
        count = 0

    if count >= 4:
        print ("starting script \n")
        count = 0
        os.system(remove_dev)
        os.system(pair_script)
