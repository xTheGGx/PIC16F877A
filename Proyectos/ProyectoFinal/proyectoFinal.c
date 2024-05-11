#include <16F877A.h>             // biblioteca del microcontrolador
#device ADC=10                   // establece el convertidor A/D en 10 bits resolución
#fuses HS,NOWDT,NOPROTECT,NOLVP, NOPUT, BROWNOUT  // par�metros f�sicos- el�ctricos del controlador
#use delay(clock=20M)       // 20 MHz establece el reloj a utilizar
#use standard_io(D)
// utiliza estándar rs232 con la configuración:
//   transmite por portC.6 y recibe por portC.7 con 9600 bauds
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#define use_portd_lcd true       // establece el PORTD como conexión del display LCD
#include <lcd.c>                 //biblioteca para control de display LCD.
#org 0x1F00, 0x1FFF void loader16F877(void) {} // reserva la memoria donde esta el bootloader


float temperatura;   // variable para almacenar la lectura de temperatura
float voltaje;       // variable para almacenar la lectura de voltaje
float corriente;     // variable para almacenar la lectura de corriente
INT16 lectura;       // variable para guardar temporalmente lectura digital
int dentro;          // indica si se est� en el men� o midiendo
int estado;          // estado en el que está el menú

// Se muestra el mensaje de bienvenida
void inicioLCD() {
   lcd_gotoxy(2,1);  
   printf(lcd_putc," Equipo 2:\n"); 
   delay_ms(45);     
   lcd_gotoxy(1,2);
   printf(lcd_putc," Alcantar Vianey ");
   delay_ms(45);
   lcd_gotoxy(1,2);
   printf(lcd_putc," Sanchez Alexis ");
   delay_ms(45);
   lcd_gotoxy(1,2);
   printf(lcd_putc," Velazquez Karla ");
   delay_ms(45);
   lcd_gotoxy(1,1);
   printf(lcd_putc,"\f");
   printf(lcd_putc,"Proyecto Final  ");
   delay_ms(45);
}

// Funcion para mostrar el men� inicial
void imprimeMenu() {
   switch (estado){
      case 0:
         lcd_gotoxy(1,2);
         printf(lcd_putc,"   Voltaje     ");
         lcd_gotoxy(1,1);
         printf(lcd_putc,"  *Temperatura ");
         break;
      case 1:
         lcd_gotoxy(1,1);
         printf(lcd_putc,"   Temperatura ");
         lcd_gotoxy(1,2);
         printf(lcd_putc,"  *Voltaje     ");
         break;
      case 2:
         lcd_gotoxy(1,2);
         printf(lcd_putc,"   Corriente   ");
         lcd_gotoxy(1,1);
         printf(lcd_putc,"  *Voltaje     ");
         break;
      case 3:
         lcd_gotoxy(1,1);
         printf(lcd_putc,"   Voltaje     ");
         lcd_gotoxy(1,2);
         printf(lcd_putc,"  *Corriente   ");
         break;
      default:
         break;
   }
}

// Funci�n que muestra el estado actual de lectura
void imprimeLectura() {
   lcd_gotoxy(1,1);
   switch (estado){
      case 0:
         set_adc_channel(0);                       // Configura el canal 0 para usar
         delay_us(20);                             // Retardo de 20 us
         lectura = read_adc();                     // obtiene el resultado de A/D
         temperatura = (lectura * 500.0)/ 1023.0;  // ecuación lineal temper.  �C
         printf(lcd_putc," Temperatura:   ");
         lcd_gotoxy(1,2);
         printf(lcd_putc,"   %04.1f C   ", temperatura);
         delay_ms(50);
         break;
      case 1:
      case 2:
         set_adc_channel(1);     // Configura el canal 1 para usar
         delay_us(20);           // Retardo de 20 us
         lectura = read_adc();   // obtiene el resultado de A/D
         voltaje = (lectura *0.0200098913771142) ;  // ecuación lineal voltaje V
         printf(lcd_putc," Voltaje:       "); 
         lcd_gotoxy(1,2);
         printf(lcd_putc,"    %0.2f V      ", voltaje);
         break;
      case 3:
         set_adc_channel(2);     // Configura el canal 2 para usar
         delay_us(20);           // Retardo de 20 us
         lectura = read_adc();   // obtiene el resultado de A/D
         corriente = (lectura * 4.898007588791137);   // ecuación lineal corriente mA
         printf(lcd_putc," Corriente:     ");
         lcd_gotoxy(1,2);
         printf(lcd_putc,"    %05.1f mA    ", corriente);
         break;
      default:
         break;
   }
}


// Control de interrupciones de los botones
#INT_RB
void port_rb(){
   int back  = !input_state(PIN_B4);   // button back
   int enter = !input_state(PIN_B5);   // button enter
   int down  = !input_state(PIN_B6);   // button abajo
   int up    = !input_state(PIN_B7);   // button arriba

   if (dentro) {  
      if (back) {
         dentro = 0;
         imprimeMenu();
      }
      return;
   }

   if (enter) {  
      dentro = 1;
      imprimeLectura();
      return;
   }

   // cambia el estado segun el boton presionado
   switch (estado) {
      case 0:
         if (down) {
            estado = 1;
            imprimeMenu();
         }
         break;
      case 1:
      case 2:
         if (up) {
            estado = 0;
            imprimeMenu();
         }else if (down) {
            estado = 3;
            imprimeMenu();
         }
         break;
      case 3:
         if (up) {
            estado = 2;
            imprimeMenu();
         }
         break;
      default:
         break;
   } // end switch
   return;
}


int main() {

   //Inicializa lcd y convertidor ADC
   enable_interrupts(INT_RB);    
   enable_interrupts(GLOBAL);    
   lcd_init();                  
   setup_port_a(ALL_ANALOG);     
   setup_adc(ADC_CLOCK_INTERNAL);
   // Inicializa variables
   estado = 0;
   dentro = 0;
   lectura = 0;
   temperatura = 0;
   voltaje = 0;
   corriente = 0;
   //Mensajes de bienvenida
   inicioLCD();   
   //Men
   imprimeMenu(); 
   //Ciclo de trabajo
   while(true) {
      
      if (dentro){
         imprimeLectura();
      }
      delay_ms(10);
   } // end while
   
   return 0;
} //end main

