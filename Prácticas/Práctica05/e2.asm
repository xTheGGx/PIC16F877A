processor 16f877
include<p16f877.inc>
;VALORES Para la rutina de retardo
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 03h
cte2 equ 50h
cte3 equ 60h
org 0h
goto INICIO
org 05h
;VALORES PARA RETRASOS DE CADA ESTADO
contadorEdo1 equ 0x24
contadorEdo2 equ 0x25

INICIO:
				CLRF 	PORTA
				BSF 	STATUS,RP0 ;Cambia la banco 1
				BCF 	STATUS,RP1
				MOVLW 	0X00
				MOVWF 	TRISB ;Configura puerto B como salida
				MOVLW 	06h ;Configura puertos A y E como digitales
				MOVWF 	ADCON1
				MOVLW 	3fh ;Configura el puerto A como entrada
				MOVWF 	TRISA
				BCF 	STATUS,RP0 ;regresa al banco 0
				

LOOP:			
				BSF		PORTB,4
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
				MOVLW	0X00
				MOVWF	PORTB
				GOTO 	LOOP
UNO:
				MOVLW 	0X01
				MOVWF 	contadorEdo1
LOOP_ESTADO_1
				CALL 	retardo
				MOVLW 	b'10000000'
				MOVWF 	PORTB
				CALL 	retardo
				MOVLW 	b'01000000'
				MOVWF 	PORTB
				CALL 	retardo
				MOVLW 	b'00010000'
				MOVWF 	PORTB
				CALL 	retardo
				MOVLW 	b'00010000'
				MOVWF 	PORTB
				CALL 	retardo
				DECFSZ 	contadorEdo1
				GOTO	LOOP_ESTADO_1
				SLEEP
DOS:
				MOVLW 0X01
				MOVWF contadorEdo2
LOOP_ESTADO_2
				CALL retardo
				MOVLW b'00010000'
				MOVWF PORTB
				CALL retardo
				MOVLW b'00100000'
				MOVWF PORTB
				CALL retardo
				MOVLW b'01000000'
				MOVWF PORTB
				CALL retardo
				MOVLW b'10000000'
				MOVWF PORTB
				CALL retardo
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

retardo movlw cte1 ;Rutina que genera un DELAY
movwf valor1
tres movwf cte2
movwf valor2
dos movlw cte3
movwf valor3
uno decfsz valor3
goto uno
decfsz valor2
goto dos
decfsz valor1
goto tres
return
end