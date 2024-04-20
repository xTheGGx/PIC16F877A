processor 16f877 					;Indica la versión de procesador
include <p16f877.inc> 				;Incluye la librería de la versión del procesador
				valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 0DFh
cte2 equ 50h
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
				BCF 	STATUS,RP0 	;Regresa al banco cero
LOOP:			;Modo de direccionamiento indexado
				MOVF 	PORTA,W		; W <- (PORTA)
				ANDLW	0x07			; 
				ADDWF	PCL,F
				GOTO 	APAGADOS	;PC + 0
				GOTO	ENCENDIDOS	;PC * 1
				GOTO	CORR_DER	;PC * 2
				GOTO	CORR_IZQ	;PC + 3
				GOTO	PONG        ;PC + 4
				GOTO 	ON_OFF  	;PC + 5
				GOTO	APAGADOS    ;PC + 6
				GOTO	APAGADOS    ;PC + 7

APAGADOS:		CLRF	PORTB
				GOTO	LOOP

ENCENDIDOS:		MOVLW	B'11111111'
				MOVWF	PORTB
				GOTO	LOOP
CORR_DER:		
				BCF		STATUS,C
				MOVLW 	b'00000001'
				MOVWF	PORTB
				
NO_TERMINA:		CALL 	RETARDO
				RLF		PORTB,1
				CALL 	RETARDO
				BTFSS	PORTB,7
				GOTO	NO_TERMINA
				

				GOTO 	LOOP
CORR_IZQ:
				BCF		STATUS,C
				MOVLW 	b'10000000'
				MOVWF	PORTB
				
NO_TERMINA2:	CALL 	RETARDO
				RRF		PORTB,1
				CALL 	RETARDO
				BTFSS	PORTB,0
				GOTO	NO_TERMINA2

PONG:			
				BCF		STATUS,C
				MOVLW 	b'10000000'
				MOVWF	PORTB
				
NO_TERMINA3:	CALL 	RETARDO
				RRF		PORTB,1
				CALL 	RETARDO
				BTFSS	PORTB,0
				GOTO	NO_TERMINA3
				
NO_TERMINA4:	CALL 	RETARDO
				RLF		PORTB,1
				CALL 	RETARDO
				BTFSS	PORTB,7
				GOTO	NO_TERMINA4
				GOTO 	LOOP

ON_OFF:
				MOVLW	00H
				MOVWF	PORTB
				CALL	RETARDO
				MOVLW	0FFH
				MOVWF	PORTB
				CALL	RETARDO
				GOTO 	LOOP

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
