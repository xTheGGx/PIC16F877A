#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=20000000)
#include <lcd.c>
void main() {

 lcd_init();

 while( TRUE ) {
 lcd_gotoxy(1,1);
 printf(lcd_putc," UNAM \n ");
 lcd_gotoxy(1,2);
 printf(lcd_putc," FI \n ");
 delay_ms(300);
 }
 }
