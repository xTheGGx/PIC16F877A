processor 16f877
include<p16f877.inc>
			CBLOCK 0X20
				VAL 	
				VAL2	
				VAL3	
				AUX		
				VALUE	
				TEMP	
				UNIDADES
				DECENAS
				CENTENAS
			ENDC	
		
			ORG 0
			GOTO INICIO
			ORG 5	


INICIO:		;Configuración del puerto serie
			CLRF	PORTA
			BSF 	STATUS,RP0
			BCF 	STATUS,RP1
			BSF 	TXSTA,BRGH		;Define una taza alta
			CLRF	ADCON1			;CONFIGURA PORTA COMO ENTRADA ANALOGICA
			MOVLW 	D'129'			;Configura la taza de transferencia 9600 [bauds]
			MOVWF 	SPBRG			;129 con BRGH en 1 a 9600 [bauds]
			BCF 	TXSTA,SYNC      ;Indicamos comunicación asíncrona, bit SYNC en 0
			BSF 	TXSTA,TXEN		;Habilitamos el transmisor del microcontrolador
			CLRF	TRISB			;PORTB como salida			;Asincrona (sincronizar la transferencia de información)
			BCF 	STATUS,RP0		;Regresamos a banco 0

			BSF 	RCSTA,SPEN		;Habilita el puerto serie
			BSF 	RCSTA,CREN		;Habilitamos la recepción continua (Si la bandera esta en 0, se recibe 1 dato, no un flujo constante de datos para ello la bandera se 'habilita' con 1)			
;COMPUTER CAMBIA LA TEMPERATURA AMBIENTE Y MUESTRALA EN LA TERMINAL PORFAVOR
REPITE:		;Ahora la acción que queremos realizar
			CLRF	UNIDADES
			CLRF	DECENAS
			CLRF	CENTENAS
			MOVLW	B'11101001'
			MOVWF	ADCON0
			BSF		ADCON0,2		;ACTIVAMOS	GO/DONE
			CALL	RETARDO_AC		;RETARDO DE 200 MICROSEGUNDOS
ESPERA:		BTFSC	ADCON0,2
			GOTO	ESPERA			;ESPERA A CONCLUYA EL PROCESO DE CONVERSION
			MOVFW	ADRESH			;LEEMOS RESULTADO DE REGISTRO ADRESH Y LO GUARDAMOS EL W		
			MOVWF	TEMP			;ALMACENAMOS EL RESULTADO EN VARIBALE TEMP
			;OPERAR ENTRADA
			ADDWF 	TEMP,W
			CALL	CONVER
			;TRANSMITIR 
			MOVFW	CENTENAS
			ADDLW	0X30
			CALL	TRANSMITE
			MOVFW	DECENAS
			ADDLW	0X30
			CALL	TRANSMITE
			MOVFW	UNIDADES
			ADDLW	0X30
			CALL	TRANSMITE
			MOVLW	A'C'
			CALL	TRANSMITE
			MOVLW	0XF8
			CALL	TRANSMITE
			MOVLW	0X0A			;SALTO DE LINEA
			CALL	TRANSMITE
			MOVLW	0X0D			;RETORNO DE CARRO
			CALL	TRANSMITE
			CALL	RETARDO
			GOTO	REPITE

 	


RETARDO:
			MOVLW	D'20'
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

RETARDO_AC:
			MOVLW	D'255'
			MOVWF	VALUE
CICLO		DECFSZ	VALUE
			GOTO	CICLO	
			RETURN

			;Entra contenido de registro W
TRANSMITE:	MOVWF 	TXREG			;Se envia a transmisión
			BSF 	STATUS,RP0		;Cambio de banco
T_LOOP		BTFSS 	TXSTA,TRMT		;Pregunto si ya se recibio el dato
			GOTO 	T_LOOP			;0 no se ha recibido el dato
			BCF 	STATUS,RP0		;1 se ha recibido el dato, cambiamos de banco	
			RETURN
			;Sale dato recibido en registro W
RECIBE:		BTFSS 	PIR1,RCIF		;Status de la bandera RCIF? 1 cuando le ha llegado un dato
			GOTO 	RECIBE			;0 no ha recibido un dato
			MOVF 	RCREG,W			;1 se ha recibido un dato, transfiere el dato al registro RCREG
			RETURN
CONVER:
			MOVWF	AUX
CENTENAS_LOOP:
       		MOVLW   .100            ; Valor para restar (100 decimal)
        	SUBWF   AUX, W         ; Intenta restar 100
        	BTFSS   STATUS, C       ; Si hay carry, el resultado es negativo, salta
			GOTO    DECENAS_LOOP    ; Procede a convertir decenas si no se puede restar m?s centenas
        	INCF    CENTENAS, F     ; Incrementa las centenas
        	MOVWF   AUX            ; Actualiza TEMP con el nuevo valor
        	GOTO    CENTENAS_LOOP   ; Intenta restar 100 nuevamente
; Convertir a Decenas
DECENAS_LOOP:
        	MOVLW   .10             ; Valor para restar (10 decimal)
        	SUBWF   AUX, W         ; Intenta restar 10
        	BTFSS   STATUS, C       ; Si hay carry, el resultado es negativo, salta
        	GOTO    UNIDADES_LOOP   ; Procede a convertir unidades si no se puede restar m?s decenas
        	INCF    DECENAS, F      ; Incrementa las decenas
        	MOVWF   AUX            ; Actualiza TEMP con el nuevo valor
        	GOTO    DECENAS_LOOP    ; Intenta restar 10 nuevamente
; Ajuste de Unidades
UNIDADES_LOOP:
        	MOVF    AUX, W         ; Mueve el valor restante a W
        	MOVWF   UNIDADES        ; Almacena el valor final como unidades

   		 RETURN
			END						;Fin del programa
