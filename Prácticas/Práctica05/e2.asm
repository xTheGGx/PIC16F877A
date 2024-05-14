processor 16f877
include<p16f877.inc>
;VALORES Para la rutina de retardo
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
CTE1 equ 11h
CTE2 equ 50h
CTE3 equ 60h
org 0h
goto INICIO
org 05h
;VALORES PARA RETRASOS DE CADA ESTADO
contadorEdo1 equ 0x24
contadorEdo2 equ 0x25

INICIO:
				clrf PORTA
				bsf STATUS,RP0 ;Cambia la banco 1
				bcf STATUS,RP1
				movlw h'00'
				movwf TRISB ;Configura puerto B como salida
				clrf PORTB
				movlw 06h ;Configura puertos A y E como digitales
				movwf ADCON1
				movlw 3fh ;Configura el puerto A como entrada
				movwf TRISA
				bcf STATUS,RP0 ;regresa al banco 0

LOOP:
				MOVF 	PORTA,W		; W <- (PORTA)
				ANDLW	0x07		; 
				ADDWF	PCL,F
				GOTO 	CERO		;PC + 0
				GOTO	UNO			;PC * 1
				GOTO	DOS			;PC * 2
				GOTO	TRES		;PC + 3
				GOTO	CUATRO		;PC + 4
				GOTO 	CERO  		;PC + 5
				GOTO	CERO    	;PC + 6
				GOTO	CERO		;PC + 7

CERO:
				MOVLW 0X00
				MOVWF PORTB
				GOTO LOOP
UNO:
				MOVLW 0X01
				MOVWF contadorEdo1
LOOP_ESTADO_1
				CALL RETARDO
				MOVLW b'10000000'
				MOVWF PORTB
				CALL RETARDO
				MOVLW b'01000000'
				MOVWF PORTB
				CALL RETARDO
				MOVLW b'00100000'
				MOVWF PORTB
				CALL RETARDO
				MOVLW b'00010000'
				MOVWF PORTB
				CALL RETARDO
				DECFSZ contadorEdo1
				GOTO LOOP_ESTADO_1
				SLEEP
DOS:
				MOVLW 0X01
				MOVWF contadorEdo2
LOOP_ESTADO_2
				CALL RETARDO
				MOVLW b'00010000'
				MOVWF PORTB
				CALL RETARDO
				MOVLW b'00100000'
				MOVWF PORTB
				CALL RETARDO
				MOVLW b'01000000'
				MOVWF PORTB
				CALL RETARDO
				MOVLW b'10000000'
				MOVWF PORTB
				CALL RETARDO
				DECFSZ contadorEdo2
				GOTO LOOP_ESTADO_2
				SLEEP
TRES:
				MOVLW 0X05;
				MOVWF contadorEdo1
				GOTO LOOP_ESTADO_1
CUATRO:
				MOVLW 0X0A
				MOVWF contadorEdo2
				GOTO LOOP_ESTADO_2


;50ms -> cte3 = 250
;20 ms -> CT2 = 100
;2 ms ->	CT2 = 10
;1.5 ms  -> CTE2 = 7
;1 ms  -> CTE = 5
RETARDO:		
				MOVLW	D'1'
				MOVWF	CTE3
BUCLE3:
				MOVLW	D'2'
				MOVWF	CTE2
BUCLE2:			NOP	
				MOVLW	D'250'		;1cy
				MOVWF	CTE1		;1cy
BUCLE1:			NOP					;1cy
				DECFSZ	CTE1,F		;1cy
				GOTO	BUCLE1		
				DECFSZ	CTE2,F
				GOTO	BUCLE2
				DECFSZ	CTE3,F
				GOTO	BUCLE3
				RETURN
´

END