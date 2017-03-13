#include "adc.h"
#include "tmr0.h"
#include "serial_device.h"
#include "control_TMR0.h"

#include <avr/interrupt.h>
#include <stdio.h> //pel serial

static int32_t s_1[8]; //s-1
static int32_t s_2[8]; //s-2
static int16_t b[8] = {436,419,400,380,298,258,202,143}; //calculats amb l'octave. octave_b.png
static volatile int n = 0; //comptador per saber quin calcul de goertzel s'ha de fer.
static int32_t potencies[8];


static int uart_putchar(char c, FILE *stream);
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL,_FDEV_SETUP_WRITE);
static int uart_putchar(char c, FILE *stream){
  if (c == '\n')
    uart_putchar('\r', stream);
  loop_until_bit_is_set(UCSR0A, UDRE0);
  UDR0 = c;
  return 0;
}


static void calcula_potencia(void){
  for(int i=0; i<8; i++){
    potencies[i]=((int32_t)s_1[i]*s_1[i] + (int32_t)s_2[i]*s_2[i] - ((((int32_t)b[i]*s_1[i])>>8) * s_2[i]));
    if(potencies[i]>9000000){
      printf("p:%li-%d\n",potencies[i],i);
    }
  }
}

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
  stdout = &mystdout;
  while(1){
    if(n > 204){
    //cli();
      calcula_potencia();
      n=0;
      for (int i =0; i<8; i++){
        s_1[i]=0;
        s_2[i]=0;
      }
    }
    //sei();
  }
}

ISR(TIMER0_COMPA_vect){
   PORTD |= (1<<PD4);
   uint8_t value=read8_ADC();
   start_ADC();
   //Goertzel valors.
   int16_t s;
   //s(1)=x(1);
   if (n == 0){
     for(int i = 0; i<8; i++){
       s_1[i] = value;}
   }

   //s(2)=x(2)+2*cos(wo)*s(1);
   else if (n == 1){
     for(int i=0; i<8; i++){
       s_2[i] = value + ((int32_t)b[i]*s_1[i]>>8);
     }
   }
   //s(n)=x(n)+2*cos(wo)*s(n-1)-s(n-2);
   //tractar el primer bucle aqui del octave.
   else{
     for(int i=0; i<8; i++){
       s = value + (((int32_t)b[i]*s_1[i])>>8)-s_2[i];
       s_2[i] = s_1[i];
       s_1[i] = s;
     }
   }
   n++;
   PORTD &= ~(1<<PD4);
}
