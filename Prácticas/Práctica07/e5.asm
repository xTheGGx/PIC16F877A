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
			BCF		TRISC,1
			BCF		TRISC,2
			BCF 	STATUS,RP0		;Regresamos a banco 0
			
			BSF 	RCSTA,SPEN		;Habilita el puerto serie
			BSF 	RCSTA,CREN		;Habilitamos la recepción continua (Si la bandera esta en 0, se recibe 1 dato, no un flujo constante de datos para ello la bandera se 'habilita' con 1)
			CLRF	PORTB			;LIMPIA REGISTRO PORTB
			BCF		PORTC,1
			BCF		PORTC,2

REPITE:		;Ahora la acción que queremos realizar
			CLRF	PORTB
			CALL	RETARDO
			CALL	RECIBE
			MOVWF	AUX				;AUX GUARDA DATO RE1CIBIDO
			;D?
			MOVLW	0X44			;W <- 44 ASCII
			SUBWF	AUX,0			;W <- AUX - 44
			BTFSC	STATUS,Z		;AUX = D?
			GOTO	DERECHA			;NO ES CERO
			;d?
			MOVLW	0X64			;W <- 64 ASCII
			SUBWF	AUX,0			;W <- AUX - 64
			BTFSC	STATUS,Z		;AUX = d?
			GOTO	DERECHA			;NO ES CERO
			;I?
			MOVLW	0X49			;W <- 49 ASCII
			SUBWF	AUX,0			;W <- AUX - 49
			BTFSC	STATUS,Z		;AUX = I?
			GOTO	IZQUIERDA		;NO ES CERO
			;i?
			MOVLW	0X69			;W <- 69 ASCII
			SUBWF	AUX,0			;W <- AUX - 69
			BTFSC	STATUS,Z		;AUX = i?
			GOTO	IZQUIERDA		;NO ES CERO
		
			GOTO	REPITE
DERECHA:
			BSF		PORTB,7
LOOP_D		BCF		STATUS,C
			CALL	RETARDO
			RRF		PORTB,1
			BTFSS	PORTB,0
			GOTO	LOOP_D
			CALL	RETARDO
			RRF		PORTB,1
			GOTO	REPITE

IZQUIERDA:	
			BSF		PORTB,0
LOOP_I		BCF		STATUS,C
			CALL	RETARDO
			RLF		PORTB,1
			BTFSS	PORTB,7
			GOTO	LOOP_I
			CALL	RETARDO
			RLF		PORTB,1
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
			MOVLW	D'20'			;Medio segundo 
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
