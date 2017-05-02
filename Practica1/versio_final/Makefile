.PHONY : loadmain
loadmain: DTMF.hex
	avrdude -c arduino -p atmega328p -P /dev/cu.usbmodem1421 -U DTMF.hex
	rm -f *~ *.hex DTMF
	picocom /dev/cu.usbmodem1421 -b 115200

DTMF:  serial_device.c  control_TMR0.c control_TMR0.h adc.c adc.h tmr0.c tmr0.h DTMF.c
# opcio 1 standard: 2368 bytes
	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -DF_CPU=16000000UL DTMF.c serial_device.c  control_TMR0.c adc.c tmr0.c -o DTMF

# opcio 2 minimized 2014 bytes
#	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -Wl,-u,vfprintf -lprintf_min -DF_CPU=16000000UL osc.c serial_device.c  control_TMR0.c -o osc

# opcio 3 with float 3888 bytes
##	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -Wl,-u,vfprintf -lprintf_flt -lm -DF_CPU=16000000UL DTMF.c serial_device.c  control_TMR0.c adc.c tmr0.c -o DTMF

DTMF.hex: DTMF
	avr-objcopy -Oihex DTMF DTMF.hex
