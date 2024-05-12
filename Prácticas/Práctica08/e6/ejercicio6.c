#include <16f877.h> //Librería del controlador PIC16f877
#fuses HS,NOPROTECT, //Directivas de ADCON1
#use delay(clock=20000000) //Velocidad del reloj de la tarjeta
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7) //Directivas para poder trabajar con el puerto serie, baud rate de 38,400, PIN 6 para la transmisión de datos y PIN 7 para la recepción de datos 
#org 0x1F00, 0x1FFF void loader16F877(void) {} //for the 8k 16F876/7


void main() {
   char c; //variable para leer el caractér de antrada
   int dato,i; //variable con el dato de salida y para el contador de los ciclos para los retardos
   //delay_ms(500); // Retardo inicial de 500 ms
   
   while(1) {
   printf("Indica el dato\n"); //Pedimos el dato al usuario para que este seleccione la acción a realizar
   c=getch(); //Se obtiene el caractér del teclado con la función getchar()
   putc(c); //Se envía el caractér al flujo de datos
     switch(c) { //switch case con el valor de c
      case '0': //c = 0
         printf("\n\tLeds apagados"); //Se apagan los LEDs del puerto de salida
         output_b(0x00); // Todos los bits apagados
         delay_ms(500); //retardo de medio segundo
         break;
      case '1': //c = 1
         printf("\n\tLeds encendidos"); //Se prenden los LEDs del puerto de salida
         output_b(0xff); //// Todos los bits encendidos
         delay_ms(500); //retardo de medio segundo
         break;
      case '2': //c = 2
          printf("\n\tCorrimiento a la derecha"); //Se indica en pantalla que se hace un corrimiento a la derecha
          dato=0x80; //dato=80h
         for(int i=0;i<=7;i++)
            {
               output_b(dato); //se manda a la salida dato
               delay_ms(500); //retardo de medio segundo
               dato=dato>>1; //corrimiento a la derecha de un bit
            }
          break;
      case '3': //c = 3
         printf("\n\tCorrimiento a la izquierda"); //Se indica en pantalla que se hace un corrimiento a la izquierda
         dato=0x01; //dato=01h
         for(i=0;i<=7;i++)
            {
               output_b(dato); //se manda a la salida dato
               delay_ms(500); //retardo de medio segundo
               dato=dato<<1; //corrimiento a la izquierda de un bit
            }
         break;
      case '4': //c = 4
         printf("\n\tCorrimiento a la derecha"); //Se indica en pantalla que se hace un corrimiento a la derecha
         dato=0x80;
         for(i=0;i<=7;i++)
            {
               output_b(dato); //se manda a la salida dato
               delay_ms(500); //retardo de medio segundo
               dato=dato>>1; //corrimiento a la derecha de un bit
            }
            printf("\n\tCorrimiento a la izquierda"); //Se indica en pantalla que se hace un corrimiento a la izquierda
         dato=0x01;
         for(i=0;i<=7;i++)
            {
               output_b(dato); //se manda a la salida dato
               delay_ms(500); //retardo de medio segundo
               dato=dato<<1; //corrimiento a la izquierda de un bit
            }
         break;
      case '5': //c = 5
         printf("\n\t Apagado y encendido de LEDS"); //Se apagan y encienden los bits
         output_b(0x00); // Apagar todos los bits
         delay_ms(500); // Retardo de 500 ms
         output_b(0xff); // Encender todos los bits
         delay_ms(500); // Retardo de 500 ms
         output_b(0x00);
         break;
      default:
         // Accion por defecto en caso de comando no reconocido
         break;
      }
      
   }
}

