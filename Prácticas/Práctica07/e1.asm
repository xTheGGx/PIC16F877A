processor 16f877
include<p16f877.inc>
			
			ORG 0
			GOTO INICIO
			ORG 5

INICIO:		;Configuración del puerto serie
			BSF 	STATUS,RP0
			BCF 	STATUS,RP1
			BSF 	TXSTA,BRGH		;Define una taza alta
			MOVLW 	D'129'			;Configura la taza de transferencia 9600 [bauds]
			MOVWF 	SPBRG			;129 con BRGH en 1 a 9600 [bauds]
			BCF 	TXSTA,SYNC      ;Indicamos comunicación asíncrona, bit SYNC en 0
			BSF 	TXSTA,TXEN		;Habilitamos el transmisor del microcontrolador
									;Asincrona (sincronizar la transferencia de información)
			BCF 	STATUS,RP0		;Regresamos a banco 0
			
			BSF 	RCSTA,SPEN		;Habilita el puerto serie
			BSF 	RCSTA,CREN		;Habilitamos la recepción continua (Si la bandera esta en 0, se recibe 1 dato, no un flujo constante de datos para ello la bandera se 'habilita' con 1)			
			;Ahora la acción que queremos realizar
RECIBE:		BTFSS 	PIR1,RCIF		;Status de la bandera RCIF? 1 cuando le ha llegado un dato
			GOTO 	RECIBE			;0 no ha recibido un dato
			MOVF 	RCREG,W			;1 se ha recibido un dato, transfiere el dato al registro RCREG
			MOVWF 	TXREG			;Se envia a transmisión
			BSF 	STATUS,RP0		;Cambio de banco
TRASMITE:	BTFSS 	TXSTA,TRMT		;Pregunto si ya se recibio el dato
			GOTO 	TRASMITE		;0 no se ha recibido el dato
			BCF 	STATUS,RP0		;1 se ha recibido el dato, cambiamos de banco
			GOTO 	RECIBE			;Repetimos
			END						;Fin del programa