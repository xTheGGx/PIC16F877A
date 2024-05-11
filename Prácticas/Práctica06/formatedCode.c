#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=20000000)
#include <lcd.c>
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

void main() {
    byte leds;
    char input_char; // Variable para almacenar el carácter de entrada
    lcd_init();
    set_tris_a(0xFF);   // PortA como entrada
    set_tris_b(0x00);   // PortB como salida

    // Leer un carácter de la terminal
    while (1)
    {
        input_char = getc();
        switch(input_char) {
            case 0:
                output_b(0x00); 
                break;
            case 1:
                output_b(0xFF); 
                break;
            case 2:
                leds = ((leds >> 1) | (leds << 7)); // Rotación a la derecha
                output_b(leds);
                delay_ms(500);
                break;
            case 3:
                // Código para caso 3
                break;
            case 4:
                // Código para caso 4
                break;
            case 5:
                // Código para caso 5
                break;
            default:
                output_b(0x00); // Valor por defecto
        } 
    }
    
}
