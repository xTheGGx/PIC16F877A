#include <16f877.h> //BIBLIOTECA DEL PROCESADOR
#fuses HS,NOPROTECT, //USAMOS EL OSCILADOR, LA MEMORIA PUEDE SER REESCRITA SIN RESTRICCIONES
#use delay(clock=20000000) //frecuencia del oscilador para los retardos
#use rs232(baud=38400, xmit=PIN_C6, rcv=PIN_C7)//tx y rx configuracion despues del baudrate para permitir el flujo de informacion en puerto C
#org 0x1F00, 0x1FFF void loader16F877(void) {} //for the 8k 16F876/7 bootloader
void main(){ //MAIN
  char c; //DECLARAMOS LA VARIABLE QUE LEER� EL INPUT DEL TECLADO
  int dato, i; //DECLARAMOS DATO (SALIDA DE LOS LEDS) E I (CONTADOR DE LOS FOR)
  
  while(1){ //CICLO
    printf(" Introduzca una opcion: \n\r"); //se envia el mensaje en la hiperterminal
    //printf(" 0. Todos los bits apagados\n\r"); //se envia el mensaje en la hiperterminal
    //printf(" 1. Todos los bits encendidos\n\r"); //se envia el mensaje en la hiperterminal
    //printf(" 2. Corrimiento hacia la derecha \n\r"); //se envia el mensaje en la hiperterminal
    //printf(" 3. Corrimiento hacia la izquierda \n\r"); //se envia el mensaje en la hiperterminal
    //printf(" 4. Corrimiento hacia la derecha y a la izquierda \n\r"); //se envia el mensaje en la hiperterminal
    //printf(" 5. Apagar y encender todos los bits. \n\r"); //se envia el mensaje en la hiperterminal
    c = getch(); //LEEMOS EL INPUT DEL TECLADO
    if (c == '0'){ //SE TECLEA 0:
      output_b(0x00); //se pone en 0 
      printf(" Todos los bits apagados \n\r"); //se envia el mensaje en la hiperterminal
      delay_ms(1000); // se hace una espera de 1 segundo
    }
    else if (c == '1'){ //SE TECLEA 1:
      output_b(0xFF); //se pone en 0 
      printf(" Todos los bits encendidos\n\r"); //se envia el mensaje en la hiperterminal
      delay_ms(1000); // se hace una espera de 1 segundo
    }
    else if (c == '2'){ //SE TECLEA 2:
      output_b(0x00); //se pone en 0 
      printf(" Corrimiento hacia la derecha \n\r"); //se envia el mensaje en la hiperterminal
      dato = 0x01; //ASIGNAMOS D�NDE COMENZAR� EL CORRIMIENTO
      output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
      delay_ms(500); // se hace una espera de 1 segundo
      for (i=0; i<7;i++){ //CICLO PARA EL CORRIMIENTO
          dato = (dato<<1); //HACEMOS UN CORRIMIENTO A LA DERECHA
          output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
          delay_ms(500); // se hace una espera de 1 segundo
      }
      
    }
    else if (c == '3'){ //SE TECLEA 3:
      output_b(0x00); //se pone en 0 
      printf(" Corrimiento hacia la izquierda \n\r"); //se envia el mensaje en la hiperterminal
      dato = 0x80; //ASIGNAMOS D�NDE COMENZAR� EL CORRIMIENTO
      output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
      delay_ms(500); // se hace una espera de 1 segundo
      for (i=0; i<7;i++){ //CICLO PARA EL CORRIMIENTO
          dato = (dato>>1); //HACEMOS UN CORRIMIENTO A LA IZQUIERDA
          output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
          delay_ms(500); // se hace una espera de 1 segundo
      }
    }
    else if (c == '4'){ //SE TECLEA 4:
      output_b(0x00); //se pone en 0 
      printf(" Corrimiento hacia la derecha y a la izquierda \n\r"); //se envia el mensaje en la hiperterminal
      
      dato = 0x01; //ASIGNAMOS D�NDE COMENZAR� EL CORRIMIENTO
      output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
      delay_ms(500); // se hace una espera de 1 segundo
      for (i=0; i<7;i++){ //CICLO PARA EL CORRIMIENTO
          dato = (dato<<1); //HACEMOS UN CORRIMIENTO A LA DERECHA
          output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
          delay_ms(500); // se hace una espera de 1 segundo
      }
      dato = 0x80; //ASIGNAMOS D�NDE COMENZAR� EL CORRIMIENTO
      output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
          delay_ms(500); // se hace una espera de 1 segundo
      for (i=0; i<7;i++){ //CICLO PARA EL CORRIMIENTO
          dato = (dato>>1); //HACEMOS UN CORRIMIENTO A LA IZQUIERDA
          output_b(dato); //ASIGNAMOS EL DATO AL PUERTO B
          delay_ms(500); // se hace una espera de 1 segundo
      }
    }
    else if (c == '5'){ //SE TECLEA 5:
      output_b(0xFF); //se pone en 0 
      printf(" Todos los bits encendidos \n\r"); //se envia el mensaje en la hiperterminal
      delay_ms(1000); // se hace una espera de 1 segundo
      output_b(0x00); //se pone en 0 
      printf(" Todos los leds apagados \n\r"); //se envia el mensaje en la hiperterminal
      delay_ms(1000);// se hace una espera de 1 segundo
    }
  
  }//while
}//main
