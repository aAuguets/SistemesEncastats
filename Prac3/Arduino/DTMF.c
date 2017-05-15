#include "adc.h"
#include "tmr0.h"
#include "serial_device.h"
#include "control_TMR0.h"

#include <avr/interrupt.h>
#include <stdio.h> //pel serial
#include <stdbool.h>

void setup(){
  setup_ADC(5,5,16);//(adc_input,v_ref,adc_pre)
  //adc_input (0-5 (default=5),8 Tª, 14 1.1V, 15 GND
  //v_ref 0 (AREF), 1(1.1V), default=5 (5V)
  //adc_pre 2,4,8,16(default),32,64,128
  setup_tmr0(249,8);//(ocr0a, tmr0_pre)
  //tmr0_pre 1,default=8,64,256,1024
  //TMR0=prescaler*(ocr0a+1)*T_clk
  start_ADC();
  DDRD |=(1<<DDD4);//pin 4 Arduino as an output. It shows sampling period (period) and ISR execution time (pulse wide)
  serial_init();
  sei();
}

int main(void){
  setup();
  while(1);
  return 0;
}

ISR(TIMER0_COMPA_vect){
   PORTD |= (1<<PD4);
   uint8_t value=read8_ADC();
   start_ADC();
   serial_put(value);
}
