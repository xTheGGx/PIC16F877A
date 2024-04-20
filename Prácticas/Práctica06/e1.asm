include <p16f877.inc>

VAL		EQU		0X20		;Localidad de memoria 0x20 asignada a registro VAL
		ORG		0
		GOTO	INICIO
		ORG		5

INICIO:	CLRF	PORTA		;Limpia registro PORTA nos permite recibir la señal analógica
		BSF		STATUS,RP0
		BCF		STATUS,RP1	;Mueve al banco 1
		CLRF	TRISD		;Configura registro PORTB como salida
		CLRF	ADCON1		;Limpio ADCON1, defino que el formato de resultado se carga en ADRESH, y puertos A y D como analógicos
		BCF		STATUS,RP0	;Muevo al banco 0
		MOVLW	B'11101001'	
		MOVWF	ADCON0		;ADCON0 <- 11 (frecuencia interna) 001 (QUé canal A1) 0 (Go/Done) 0(No existe) 1(convertidor)
		CLRF	PORTD
REPITE:	BSF		ADCON0,2	;GO/Done realiza la conversión
		CALL	RETARDO		;Rutina de retardo que consume el tiempo necesario
ESPERA:	BTFSC	ADCON0,2	;Espera hasta que la conversión este termunada
		GOTO	ESPERA
		MOVF	ADRESH,W	;ADRESH contiene el resultado de la conversión
		MOVWF	PORTD		;Transfiero el resultado de la conversión al puertoB
		GOTO	REPITE		;Para obtener el Voltaje de entrada hay que multiplicar la salida por 19.5 [mV]			

RETARDO:	
			MOVLW	0X250
			MOVWF	VAL
LOOP:		DECFSZ	VAL
			GOTO	LOOP	
			RETURN
	
		END