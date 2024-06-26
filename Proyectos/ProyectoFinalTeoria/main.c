#include <16f877a.h>
#fuses HS,NOWDT,NOPROTECT,NOPUT,NOLVP,BROWNOUT 
#use delay(clock=20M)
#use standard_io(D)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

// Definici�n de pines para el LCD
#define LCD_DB4   PIN_D4
#define LCD_DB5   PIN_D5
#define LCD_DB6   PIN_D6
#define LCD_DB7   PIN_D7
#define LCD_RS    PIN_D2
#define LCD_E     PIN_D3
#define DHT11_PIN PIN_B2
#include <LCD_16X2.c>  // Librer�a para el manejo de la pantalla LCD
#include <dht11_std.c> //Libreria para el manejo del sensor de humedad
// Definici�n de pines para el sensor de temperatura y el ventilador
#define TEMP_SENSOR_PIN PIN_A0
#define FAN_PIN PIN_B0
#define LAMP_PIN PIN_B1

char grade[8] = {0x07, 0x05, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00};
float temperatura;
float lectura;
float voltaje;
float conversion;
int percent;
int flag = 1;
float humedad;
int data_ok;



void tempControl(){
      // Leer el valor del sensor de temperatura
      //setup_oscillator(OSC_20MHZ);  
      set_adc_channel(0); // Selecciona el canal AN0 (PIN_A0)
      delay_us(20); // Espera el tiempo de adquisici�n del ADC

      lectura = read_adc(); // Lee el valor del ADC
      // Convertir el valor ADC a temperatura (suponiendo un LM35)
      printf("%f \n", lectura);
      temperatura = (lectura * 2); // Conversi�n para LM35
      // Mostrar la temperatura en el LCD
      lcd_gotoxy(1,1); // Columna 1, Fila 1
      printf(lcd_putc, "Temp: %0.2f C", temperatura);
      lcd_gotoxy(12,1);
      CGRAM_putc(0);
      // Controlar el ventilador basado en la temperatura
      if (temperatura > 30.0) { // Umbral de temperatura (30 grados Celsius)
         printf("Encendiendo ventilador");
         output_high(FAN_PIN); // Enciende el ventilador
      } else {
         printf("Apagando Ventilador");
         output_low(FAN_PIN); // Apaga el ventilador
      }

      delay_ms(150);
}

void lightControl(){
   set_adc_channel(1);
   delay_us(20);
   lectura = read_adc();
   voltaje = (lectura * 0.0200098913771142);
   conversion = (voltaje*100)/4.98;
   percent = 100 - conversion;
     
   lcd_gotoxy(1,1);
   printf(lcd_putc, "Luz:  %3u%% ", percent);
   if (percent < 30.0) { // Umbral de LUZ (30 PERCENT)
      printf("Encendiendo lampara");
      output_high(LAMP_PIN); // Enciende el ventilador
   } else {
      printf("Apagando lampara");
      output_low(LAMP_PIN); // Apaga el ventilador
   }
   delay_ms(500);
}

void rhControl(){
            data_ok = dht11_read_data(&humedad, &temperatura);
            if (data_ok == 1){
               lcd_clear();
               lcd_gotoxy(1,1);
               printf(lcd_putc, "Hum = %0.1f%%\r\r", humedad);
               lcd_gotoxy(1,2);
               printf(lcd_putc, "Tem = %0.1fC\r\n\r\n", temperatura);
            }else{
               lcd_clear();
               lcd_gotoxy(2,1);
               lcd_putc("No conectado");
            }
               delay_ms(1200);
            }

void main() {
   // Inicializaci�n del ADC y el LCD
   lcd_init();
   setup_adc(adc_clock_internal);
   setup_adc_ports(all_analog);
   CGRAM_position(0);
   CGRAM_create_char(grade);
   // Configuraci�n del pin del ventilador como salida
   set_tris_b(0x20); // Establece RB0 como salida (0) y los dem�s como entrada (1)
   setup_timer_1(T1_DISABLED);                         // Disable Timer1
   
   while(true) {
      
      do{  
          output_b(0x00);
          printf(lcd_putc, "\f");
          flag = 0;
          lcd_gotoxy(1, 1);                           // Go to column 1 row 1
          printf(lcd_putc, "F.I. UNAM");                 // Display message1
          delay_ms(10);
          lcd_gotoxy(1, 2);                           // Go to column 1 row 2
          printf(lcd_putc, "Alexis Sanchez");
      }while(flag == 1);
      char c = getc();
      delay_us(20);
      if(c == '1'){
         //temp control
         int tpFlag = 1;
         char tpAux = 1;
         do{
            tempControl();
            tpAux = getc();
            if (tpAux == '0'){
               tpFlag = 0;
            }
         }while(tpFlag==1);
         flag = 1;   
      }else if(c == '2'){
         //light control
         int lgFlag = 1;
         char lgAux = 1;
         do{
            lightControl();
            lgAux = getc();
            if (lgAux == '0'){
               lgFlag = 0;
            }
         }while(lgFlag==1);
         flag = 1;
         
         delay_ms(50);
         flag = 1;
         
      }else if(c == '3'){
         //rh control
         int rhFlag = 1;
         char rhAux = 1;
         do{
            rhControl();
            rhAux = getc();
            if (rhAux == '0'){
               rhFlag = 0;
            }
         }while(rhFlag==1);
         flag = 1;
      }else{
         delay_ms(50);
         flag = 1;   
      }

            
    }  
      //tempControl();
      //lightControl();
      //rhControl();
   }


