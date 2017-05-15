#include "serial_device.h"
#include "utils.h"

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>

static void setup(void){
  serial_init();
  DDRD &= 0b00001111; //0 as input
  DDRB &= 0b00000001;
}

static uint8_t descodifica(uint8_t e_portd){
  uint8_t resultat = 's';
  switch(e_portd){
  case 0b00010000:
    resultat = '1';
    break;
  case 0b00100000:
    resultat = '2';
    break;
  case 0b00110000:
    resultat = '3';
    break;
  case 0b01000000:
    resultat = '4';
    break;
  case 0b01010000:
    resultat = '5';
    break;
  case 0b01100000:
    resultat = '6';
    break;
  case 0b01110000:
    resultat = '7';
    break;
  case 0b10000000:
    resultat = '8';
    break;
  case 0b10010000:
    resultat = '9';
    break;
  case 0b10100000:
    resultat = 'A';
    break;
  case 0b10110000:
    resultat = 'B';
    break;
  case 0b11000000:
    resultat = 'C';
    break;
  case 0b11010000:
    resultat = 'D';
    break;
  case 0b11100000:
    resultat = '*';
    break;
  case 0b11110000:
    resultat = '0';
    break;
  case 0b00000000:
    resultat = '#';
    break;
  }
  return resultat;
}

int main(void){
  uint8_t e_portd;
  
  volatile uint8_t enable;

  setup();
  while(1){
    enable = PINB & 0b00000001; //mentre no sigui flanc de pujada, t'esperes aqui.
    while(enable != 0b00000001){
      enable = PINB & 0b00000001;
    }

    e_portd = PIND & 0b11110000;
    serial_put(descodifica(e_portd));

    enable = PINB & 0b00000001; //mentre no sigui flanc de baixada, t'esperes aqui.
    while(enable != 0b00000000){
      enable = PINB & 0b00000001;
    }
  }
  return 0;
}
