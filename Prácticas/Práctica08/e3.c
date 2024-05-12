#include <16f877.h>
#fuses HS,NOPROTECT,
#use delay(clock=20000000)
#org 0x1F00, 0x1FFF void loader16F877(void) {}
int var1;
void main(){
 while(1){
 var1=input_a();  //Guardamos los 8 bits del puerto portA en una variable de tipo entero
 output_b(var1);  //Mandamos el valor de la variable como salida en el puerto B
 }//while
 }//main

