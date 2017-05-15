.PHONY : loadmain
loadmain: main.hex
	avrdude -c arduino -p atmega328p -P /dev/cu.usbmodem1421 -U main.hex
	rm -f *~ *.hex main
	picocom /dev/cu.usbmodem1421

main:  serial_device.c main.c

	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -DF_CPU=16000000UL main.c serial_device.c -o main

main.hex: main
	avr-objcopy -Oihex main main.hex
