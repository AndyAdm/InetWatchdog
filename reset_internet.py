#import RPi.GPIO as GPIO
#import time
#GPIO.setmode(GPIO.BCM) # GPIO Nummern statt Board Nummern
 
#RELAIS_1_GPIO = 17
#GPIO.setup(RELAIS_1_GPIO, GPIO.OUT) # GPIO Modus zuweisen
#GPIO.output(RELAIS_1_GPIO, GPIO.LOW) # aus
#time.sleep(10)
#GPIO.output(RELAIS_1_GPIO, GPIO.HIGH) # an


from periphery import GPIO
import time

# 150 is the pin 13 / defaut = LOW
RELAIS_1_GPIO = 150 
Relais_gpio = GPIO(RELAIS_1_GPIO, "out")

Relais_gpio.write(True)
time.sleep(20)
#Relais_gpio.write(True)
#time.sleep(10)
Relais_gpio.write(False)

