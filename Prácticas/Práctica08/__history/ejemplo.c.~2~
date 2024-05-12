#include <16f877.h>
#fuses HS,NOPROTECT, //Alta velocidad, no queremos proteger el código 
#use delay(clock=20000000) //Reloj de 20 MHz
#org 0x1F00, 0x1FFF void loader16F877(void) {}//A partir de la 1f00 y hasta la 1fff vamos a reservar una función vacía
void main(){
 while(1){
 output_b(0x01);
 delay_ms(1000);
 output_b(0x00);
 delay_ms(1000);
 } //while
}//main
