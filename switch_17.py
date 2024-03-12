#import RPi.GPIO as GPIO
#from pyRock.gpio import GPIO
from periphery import GPIO
import time
#GPIO.setmode(GPIO.BCM) # GPIO Nummern statt Board Nummern
 
RELAIS_1_GPIO = 73

Relais_gpio = GPIO(RELAIS_1_GPIO, "out")
Relais_gpio.write(False)

#GPIO.setup(RELAIS_1_GPIO, GPIO.OUT) # GPIO Modus zuweisen

time.sleep(20)
Relais_gpio.write(True)

#GPIO.output(RELAIS_1_GPIO, GPIO.LOW) # aus
time.sleep(30)
Relais_gpio.write(False)

#GPIO.output(RELAIS_1_GPIO, GPIO.HIGH) # an
