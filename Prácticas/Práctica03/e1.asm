processor 16f877 					;Indica la versión de procesador
include <p16f877.inc> 				;Incluye la librería de la versión del procesador

				ORG 0H 				;Carga al vector de RESET la dirección de inicio
				GOTO inicio 		;Nos movemos a la etiqueta inicio
				ORG 05H 			;Dirección de inicio del programa del usuario

INICIO: 		CLRF 	PORTA 		;se limpia el contenido del puerto PORTA
				BSF 	STATUS,RP0 	;Cambia la banco 1
				BCF 	STATUS,RP1 
				MOVLW 	06H 		;Configura puertos A y E como digitales
				MOVWF 	ADCON1 		;
				MOVLW 	3FH 		;Configura el puerto A como entrada
				MOVWF 	TRISA
				MOVLW 	0X00	 	;Se coloca un 0 en el registro W
				MOVWF 	TRISB 		; Se configura al puerto PORTB como puerto de salida
				BCF 	STATUS,RP0 	;Regresa al banco cero
LOOP:			;Modo de direccionamiento indexado
				MOVF 	PORTA,W		; W <- (PORTA)
				ANDLW	7			; 
				ADDWF	PCL,F
				GOTO 	APAGADOS	;PC + 0
				GOTO	ENCENDIDOS	;PC * 1
				GOTO	CORR_DER	;PC * 2
				GOTO	CORR_IZQ	;PC + 3
				GOTO	PONG        ;PC + 4
				GOTO 	ON_OFF  	;PC + 5
				GOTO	APAGADOS    ;PC + 6
				GOTO	APAGADOS    ;PC + 7

APAGADOS		CLRF	PORTB
				GOTO	LOOP

ENCENDIDOS		MOVLW	FFH
				MOVFW	PORTB
				GOTO	LOOP

				GOTO 	LOOP
				END				;Fin de programa 
