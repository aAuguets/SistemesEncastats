#include "adc.h" 
#include "tmr0.h" 
#include "serial_device.h"
#include "control_TMR0.h"

#include <avr/interrupt.h> 

void setup(){
  setup_ADC(5,5,16);//(adc_input,v_ref,adc_pre)
  //adc_input (0-5 (default=5),8 Tª, 14 1.1V, 15 GND 
  //v_ref 0 (AREF), 1(1.1V), default=5 (5V)
  //adc_pre 2,4,8,16(default),32,64,128
  setup_tmr0(99,8);//(ocr0a, tmr0_pre)
  //tmr0_pre 1,default=8,64,256,1024
  //TMR0=prescaler*(ocr0a+1)*T_clk
  setup_pwm_tmr2(11);//(pwm_out) 3,default=11
  DDRD |=(1<<DDD4);//pin 4 Arduino as an output. It shows sampling period (period) and ISR execution time (pulse wide)
  sei();
}

int main(void){
  setup();
  while(1){}
}

ISR(TIMER0_COMPA_vect){
   PORTD |= (1<<PD4);
   uint8_t value=read8_ADC();
   start_ADC();
   set_pwm_tmr2(value,11);
   PORTD &= ~(1<<PD4);
}