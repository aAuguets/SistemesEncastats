#include "adc.h"
#include "tmr0.h"
#include "serial_device.h"
#include "control_TMR0.h"

#include <avr/interrupt.h>
#include <stdio.h> //pel serial
#include <stdbool.h>

#define LLINDAR 1000000
#define BAIX 0
#define ALT 1

static int32_t s_1[8]; //s-1
static int32_t s_2[8]; //s-2
static int16_t b[8] = {436,419,400,380,298,258,202,143}; //calculats amb l'octave. octave_b.png
static uint8_t resultats[16] = {'1','2','3','A','4','5','6','B','7','8','9','C','*','0','#','D'};

static volatile int n = 0; //comptador per saber quin calcul de goertzel s'ha de fer.
static int32_t potencies[8];
//maquina d'estats
typedef enum {EsperoDada, EsperoSilenci } estats;
static estats estat_senyal;
static uint8_t detectat = 0;
//static volatile uint8_t segonDetectat = 0;

static uint8_t detectaResultat(void);
void deteccioSenyals_maquinaestats(void);

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
  //bool senyalDetectat;
  for(int i=0; i<8; i++){
    potencies[i]=((int32_t)s_1[i]*s_1[i] + (int32_t)s_2[i]*s_2[i] - ((((int32_t)b[i]*s_1[i])>>8) * s_2[i]));

    //printf("%c\n", detectaResultat());//Ok. Nou test passat.
    deteccioSenyals_maquinaestats();
  }
}

uint8_t detectaResultat(void){
  //(fila*4)+(columna-4)=> posicio de la llista resultats.
  bool d_fila = false;
  bool d_columna = false;
  int trobat = 0;
  uint8_t posicio = 0;
  for(int i=0; i<4; i++){
    //files, frequencies baixes.
    if(potencies[i] > LLINDAR){
      posicio += i*4;
      trobat ++;
      d_fila = true;}
  }
  for (int i=4; i<8; i++){
    //columnes, frequencies altes.
    if(potencies[i] > LLINDAR){
      posicio += (i-4);
      trobat++;
      d_columna = true;}
  }
  if ((d_fila && d_columna) && (trobat == 2)){
    //si s'han trobat mes de 2 frequencies -> False.
    //si no s'ha trobat una frequencia baixa i una alta-> false.
    return resultats[posicio];}
  else if (trobat > 0)
    //'?' -> Unknown.
    return '?';
  else
    // '-' -> silenci.
    return '-';
}

void deteccioSenyals_maquinaestats(void){
  detectat = detectaResultat();
  switch (estat_senyal) {
    case EsperoDada:
      if ((detectat != '-') && (detectat != '?')){
        printf("%c ",detectat);
        estat_senyal = EsperoSilenci;
      }
      else
        estat_senyal = EsperoDada;

      break;
    case EsperoSilenci:
      if (detectat == '-')
        estat_senyal = EsperoDada;
      else
        estat_senyal = EsperoSilenci;
      break;
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
  estat_senyal =  EsperoDada;
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
