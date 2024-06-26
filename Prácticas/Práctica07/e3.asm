processor 16f877
include<p16f877.inc>
			
			ORG 0
			GOTO INICIO
			ORG 5
			VAL 	EQU 	0X20
			VAL2	EQU		0X21	
			VAL3	EQU		0X22
			AUX		EQU		0X23

INICIO:		;Configuración del puerto serie
			BSF 	STATUS,RP0
			BCF 	STATUS,RP1
			BSF 	TXSTA,BRGH		;Define una taza alta
			MOVLW 	D'129'			;Configura la taza de transferencia 9600 [bauds]
			MOVWF 	SPBRG			;129 con BRGH en 1 a 9600 [bauds]
			BCF 	TXSTA,SYNC      ;Indicamos comunicación asíncrona, bit SYNC en 0
			BSF 	TXSTA,TXEN		;Habilitamos el transmisor del microcontrolador
			CLRF	TRISB			;portb como salida			;Asincrona (sincronizar la transferencia de información)
			BCF 	STATUS,RP0		;Regresamos a banco 0
			
			BSF 	RCSTA,SPEN		;Habilita el puerto serie
			BSF 	RCSTA,CREN		;Habilitamos la recepción continua (Si la bandera esta en 0, se recibe 1 dato, no un flujo constante de datos para ello la bandera se 'habilita' con 1)
			CLRF	PORTB			;LIMPIA REGISTRO PORTB

REPITE:		;Ahora la acción que queremos realizar
			CALL	RETARDO
			CALL	RECIBE
			MOVWF	AUX				;AUX GUARDA DATO RE1CIBIDO
			MOVLW	0X30			;W <- 00 ASCII
			SUBWF	AUX,0			;W <- AUX - 00
			BTFSS	STATUS,Z		;AUX = 0?
			GOTO	NOCERO			;NO ES CERO
			GOTO	ESCERO			;SI, ES CERO
NOCERO:								;CONTINUA
			MOVLW	0X31			;W <- 01 ASCII
			SUBWF	AUX,0			;W <- AUX - 01
			BTFSS	STATUS,Z		;AUX = 1?
			GOTO	REPITE			;NO, VUELVE  A RECIBIR EL CARACTER
			BSF		PORTB,0			;SI, ENCIENDE EL LED
			GOTO	REPITE
ESCERO:		
			BCF		PORTB,0			;APAGA EL LED	
			GOTO	REPITE


			;MOVLW	A'M'
			;MOVWF 	TXREG			;Se envia a transmisión
			;BSF 	STATUS,RP0		;Cambio de banco
TRANSMITE:	BTFSS 	TXSTA,TRMT		;Pregunto si ya se recibio el dato
			GOTO 	TRANSMITE		;0 no se ha recibido el dato
			BCF 	STATUS,RP0		;1 se ha recibido el dato, cambiamos de banco	
			RETURN

RECIBE:		BTFSS 	PIR1,RCIF		;Status de la bandera RCIF? 1 cuando le ha llegado un dato
			GOTO 	RECIBE			;0 no ha recibido un dato
			MOVF 	RCREG,W			;1 se ha recibido un dato, transfiere el dato al registro RCREG
			RETURN

RETARDO:
			MOVLW	D'1'
			MOVWF	VAL3
LOOP3:
			MOVLW	D'250'
			MOVWF	VAL2 	
LOOP2:
			MOVLW	D'250'
			MOVWF 	VAL
LOOP: 
			DECFSZ  VAL
			GOTO 	LOOP
			DECFSZ	VAL2
			GOTO	LOOP2
			DECFSZ	VAL3
			GOTO	LOOP3
			RETURN 

			END						;Fin del programa
