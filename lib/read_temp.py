import smbus
import time

# If you're using SDA1+SCL1, set this to 1
# If you're using SDA0+SCL0, set this to 0
port = 1
bus = smbus.SMBus(port)
device_address = 0x5a

try:
    # to read the object  temperature, pass in 0x07
    # to read the ambient temperature, pass in 0x06
    reading = bus.read_word_data(device_address, 0x07)
    tempc = reading * .02 - 273.15
    tempf = (tempc * 9.0 / 5.0) + 32.0
    print(tempf)
except IOError:
    print("error")