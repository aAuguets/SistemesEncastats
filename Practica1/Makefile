.PHONY : loadmain
loadmain: GAprimer.hex
	avrdude -c arduino -p atmega328p -P /dev/ttyACM0 -U GAprimer.hex
	rm -f *~ *.hex GAprimer
	picocom /dev/ttyACM0

GAprimer:  serial_device.c  control_TMR0.c control_TMR0.h adc.c adc.h tmr0.c tmr0.h GAprimer.c
# opcio 1 standard: 2368 bytes
#	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -DF_CPU=16000000UL osc.c serial_device.c  control_TMR0.c -o osc

# opcio 2 minimized 2014 bytes
#	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -Wl,-u,vfprintf -lprintf_min -DF_CPU=16000000UL osc.c serial_device.c  control_TMR0.c -o osc

# opcio 3 with float 3888 bytes
	avr-gcc -std=c99 -Wall -Os -mmcu=atmega328p -fshort-enums -Wl,-u,vfprintf -lprintf_flt -lm -DF_CPU=16000000UL GAprimer.c serial_device.c  control_TMR0.c adc.c tmr0.c -o GAprimer

GAprimer.hex: GAprimer
	avr-objcopy -Oihex GAprimer GAprimer.hex
