#include <16f877.h>
#fuses HS,NOPROTECT, //Alta velocidad, no queremos proteger el c�digo 
#use delay(clock=20000000) //Reloj de 20 MHz
#org 0x1F00, 0x1FFF void loader16F877(void) {}//A partir de la 1f00 y hasta la 1fff vamos a reservar una funci�n vac�a
void main(){
 while(1){
 output_b(0x01);//Mandamos un 0b00000001 al portb
 delay_ms(1000);//retraso de 1 segundo
 output_b(0x00);//Mandamos un 0b00000000 al portb
 delay_ms(1000);//retraso de 1 segundo
 } //while
}//main
