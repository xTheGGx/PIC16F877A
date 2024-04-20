processor 16f877 					;Indica la versión de procesador
include <p16f877.inc> 				;Incluye la librería de la versión del procesador
				valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 01h
cte2 equ 10h
cte3 equ 60h
				ORG 0H 				;Carga al vector de RESET la dirección de inicio
				GOTO INICIO 		;Nos movemos a la etiqueta inicio
				ORG 05H 			;Dirección de inicio del programa del usuario

INICIO: 		CLRF 	PORTA 		;se limpia el contenido del puerto PORTA
				BSF 	STATUS,RP0 	;Cambia la banco 1
				BCF 	STATUS,RP1 
				MOVLW 	06H 		;Configura puertos A y E como digitales
				MOVWF 	ADCON1 		;
				MOVLW 	3FH 		;Configura el puerto A como entrada
				MOVWF 	TRISA		
							 		;Se coloca un 0 en el registro W
				CLRF 	TRISB 		; Se configura al puerto PORTB como puerto de salida
				CLRF	TRISC		; Se configura al puerto PORTC como puerto de salida
				BCF 	STATUS,RP0 	;Regresa al banco cero
LOOP:			;Modo de direccionamiento indexado
				MOVF 	PORTA,W		; W <- (PORTA)
				ANDLW	0x0F		; 
				ADDWF	PCL,F
				GOTO 	CERO		;PC + 0
				GOTO	UNO			;PC * 1
				GOTO	DOS			;PC * 2
				GOTO	TRES		;PC + 3
				GOTO	CUATRO		;PC + 4
				GOTO 	CINCO  		;PC + 5
				GOTO	SEIS    	;PC + 6
				GOTO	SIETE		;PC + 7
				GOTO 	OCHO		;PC + 8
				GOTO	CERO		;PC + 9
				GOTO	CERO		;PC + 10
				GOTO	CERO
				GOTO	CERO
				GOTO	CERO
				GOTO	CERO
				GOTO	CERO		;PC + 15

CERO:			CALL	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				CLRF	PORTB
				GOTO	LOOP

UNO:			CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00000100'
				MOVWF	PORTB
				GOTO	LOOP
DOS:		
				CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00001000'
				MOVWF	PORTB
				GOTO	LOOP
				
TRES:			CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00000001'
				MOVWF	PORTB
				GOTO	LOOP
CUATRO:
				CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00000010'
				MOVWF	PORTB
				GOTO	LOOP
				
CINCO:			CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00000101'
				MOVWF	PORTB
				GOTO	LOOP

SEIS:			
				CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00001010'
				MOVWF	PORTB
				GOTO	LOOP
				
SIETE:			CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00001001'
				MOVWF	PORTB
				GOTO	LOOP
				
OCHO:			CALL 	RETARDO
				MOVLW	B'00000110'
				MOVWF	PORTC
				MOVLW	B'00000110'
				MOVWF	PORTB
				GOTO	LOOP

RETARDO:		
				 MOVLW cte1
				 MOVWF valor1
tres MOVLW cte2
				MOVWF valor2
dos MOVLW cte3
				MOVWF valor3
uno DECFSZ valor3
				 GOTO uno
				DECFSZ valor2
				GOTO dos
				DECFSZ valor1
				GOTO tres

				return

				END				;Fin de programa