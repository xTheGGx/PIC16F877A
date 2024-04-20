include <p16f877.inc>

VAL		EQU		0X20		;Localidad de memoria 0x20 asignada a registro VAL
VAL2	EQU		0X21
AUX		EQU		0X22
AUX2	EQU		0X23
AUX3	EQU		0X24	
		
		ORG		0
		GOTO	INICIO
		ORG		5

INICIO:	CLRF	PORTA		;Limpia registro PORTA nos permite recibir la señal analógica
		BSF		STATUS,RP0
		BCF		STATUS,RP1	;Mueve al banco 1
		CLRF	TRISD		;Configura registro PORTB como salida
		CLRF	ADCON1		;Limpio ADCON1, defino que el formato de resultado se carga en ADRESH, y puertos A y D como analógicos
		BCF		STATUS,RP0	;Muevo al banco 0
		CLRF	PORTD
		;Para el canal 5
REPITE:	BCF		STATUS,C	;Limpiamos el carry
	
		MOVLW	B'11101001'	
		MOVWF	ADCON0		;ADCON0 <- 11 (frecuencia interna) 001 (QUé canal A1) 0 (Go/Done) 0(No existe) 1(convertidor)
		BSF		ADCON0,2	;GO/DONE INICIA CONVERSION
		CALL	RETARDO		;SE GENERA RETARDO
		BCF		ADCON0,2	;La conversion termina resultado en reg ADRESH
		MOVFW	ADRESH		;Guarda resultado en registro W
		MOVWF	AUX			;Guardamos conversion en var auxiliar			
		;Para el canal 6
		MOVLW	B'11110001'	
		MOVWF	ADCON0		;ADCON0 <- 11 (frecuencia interna) 001 (QUé canal A1) 0 (Go/Done) 0(No existe) 1(convertidor)
		BSF		ADCON0,2	;GO/DONE INICIA CONVERSION
		CALL	RETARDO		;SE GENERA RETARDO
		BCF		ADCON0,2	;La conversion termina resultado en reg ADRESH
		MOVFW	ADRESH		;Guarda resultado en registro W
		MOVWF	AUX2		;Guardamos conversion en var auxiliar2	
		;Para el canal 7
		MOVLW	B'11111001'	
		MOVWF	ADCON0		;ADCON0 <- 11 (frecuencia interna) 001 (QUé canal A1) 0 (Go/Done) 0(No existe) 1(convertidor)
		BSF		ADCON0,2	;GO/DONE INICIA CONVERSION
		CALL	RETARDO		;SE GENERA RETARDO
		BCF		ADCON0,2	;La conversion termina resultado en reg ADRESH
		MOVFW	ADRESH		;Guarda resultado en registro W
		MOVWF	AUX3		;Guardamos conversion en var auxiliar3	

		;Consiguiendo el voltaje mayor
		SUBWF	AUX2,W			;CANAL 6 - CANAL 7
		BTFSC	STATUS,C		;Si carry es 1 canal 6 > 7
		GOTO	CANAL6_7		;Si canal 6 es mayor a canal 7
		MOVFW	AUX3			;W <- Canal 7
		SUBWF	AUX,W			;Canal 5 - Canal 7
		BTFSC	STATUS,C		;Si carry es 1 canal 5 > 7
		GOTO	CANAL5_7		;Si canal 5 es mayor a canal7
		GOTO	CANAL7_MAYOR	;Si canal 7 es el canal mayor

CANAL6_7:
		MOVFW	AUX2			;W <- Canal 6
		SUBWF	AUX,W			;Canal 5 - Canal 6
		BTFSC	STATUS,C		;Si el canal 5 es mayor al canal 6
		GOTO	CANAL5_MAYOR	;Carry 0, 5 es mayor
		GOTO	CANAL6_MAYOR	;Carry 1, 6 es mayor
CANAL5_7:
		MOVFW 	AUX				;W <- Canal 5
		SUBWF	AUX2,W			;Canal 5 - Canal 6
		BTFSC	STATUS,C		;Si el canal 6 es mayor al canal 5
		GOTO	CANAL6_MAYOR	;Carry 0, 6 es mayor
		GOTO	CANAL5_MAYOR	;Carry 1, 5 es mayor

CANAL5_MAYOR:
		MOVLW	b'00000001'
		MOVWF	PORTD
		GOTO	REPITE
CANAL6_MAYOR:
		MOVLW	b'00000011'
		MOVWF	PORTD
		GOTO	REPITE
CANAL7_MAYOR:	
		MOVLW	b'00000111'
		MOVWF	PORTD
		GOTO	REPITE

RETARDO:	
			MOVLW	0X50
			MOVWF	VAL2
LOOP1:
			MOVLW	0X250
			MOVWF	VAL
LOOP:		DECFSZ	VAL
			GOTO	LOOP
			DECFSZ	VAL2
			GOTO	LOOP1	
			RETURN
	
		END