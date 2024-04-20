include <p16f877.inc>

VAL		EQU		0X20		;Localidad de memoria 0x20 asignada a registro VAL
AUX		EQU		0X21	
		
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
		MOVFW	ADRESH		;ADRESH contiene el resultado de la conversión
		MOVWF	AUX
		MOVLW	H'33'
		SUBWF	AUX,W		;REG_A - 33h -> W
		BTFSS	STATUS,C	;ADRESH >= 33h ?
		GOTO	MENOR_1
MAYOR_1 ;ADRESH >= 1
		MOVLW	H'66'
		SUBWF	AUX,W
		BTFSS	STATUS,C	;ADRESH >= 66h ?
		GOTO	MENOR_2
MAYOR_2: ;ADRESH >= 2
		MOVLW	H'99'
		SUBWF	AUX,W
		BTFSS	STATUS,C 	;ADRESH >= 99h ?
		GOTO	MENOR_3
MAYOR_3: ;ADRESH >= 3
		MOVLW	H'CC'
		SUBWF	AUX,W
		BTFSS	STATUS,C	;ADRESH >= CCh ? 
		GOTO	MENOR_4
MAYOR_4: ;ADRESH >= 4
		MOVLW	H'F5'
		SUBWF	AUX,W
		BTFSS	STATUS,C	;ADRESH >= F5h ?
		GOTO	MENOR_4_80
		;ADRESH > 4.80
		MOVLW	0X05
		MOVWF	PORTD
		GOTO	REPITE
MENOR_1: ;ADRESH < 1
		MOVLW	0X00
		MOVWF	PORTD
		GOTO	REPITE
MENOR_2: ;1 <= ADRESH < 2
		MOVLW	0X01
		MOVWF	PORTD
		GOTO	REPITE
MENOR_3: ;2 <= ADRESH < 3
		MOVLW 	0X02
		MOVWF	PORTD
		GOTO	REPITE
MENOR_4: ;3 <= ADRESH < 4
		MOVLW 	0X03
		MOVWF	PORTD
		GOTO	REPITE
MENOR_4_80: ;4 <= ADRESH < 4.80
		MOVLW	0X04
		MOVWF	PORTD	
		GOTO	REPITE		;Para obtener el Voltaje de entrada hay que multiplicar la salida por 19.5 [mV]			

RETARDO:	
			MOVLW	0X250
			MOVWF	VAL
LOOP:		DECFSZ	VAL
			GOTO	LOOP	
			RETURN
	
		END