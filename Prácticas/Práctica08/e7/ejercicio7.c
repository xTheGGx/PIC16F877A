#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=20000000)
#include <lcd.c>
int counter;

void main() {
  
    lcd_init();      //Inicializamos el LCD
      
    while( TRUE ) {
    int var = input_a();    
    if(var != 0){
      counter++;
      while(var != 0){
         var = input_a();
         delay_ms(10);
      }   
    }
    lcd_gotoxy(5,1);
    printf(lcd_putc,"%d d   ", counter); //Mostramos el contador en decimal
    lcd_gotoxy(5,2);
    printf(lcd_putc,"%X h   ", counter); //Mostramos el contador en hexadecimal
    delay_ms(200);
    }
 }

