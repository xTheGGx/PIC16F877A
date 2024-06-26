processor 16f877
include<p16f877.inc>


CTE1 EQU 0X20
CTE2 EQU 0X21
    ; Variables adicionales en el �rea CBLOCK si son necesarias
MILIS	EQU 0X22    ; Contador para los milisegundos
MICROS  EQU 0X23	 ; Contador para los microsegundos adicionales en retardo de 1.5ms
CUENTA	EQU	0X24

ORG 0
GOTO INICIO
ORG 5
INICIO: 		CLRF 	PORTA 		;se limpia el contenido del puerto PORTA
				BSF 	STATUS,RP0 	;Cambia la banco 1
				BCF 	STATUS,RP1 
				MOVLW 	06H 		;Configura puertos A y E como digitales
				MOVWF 	ADCON1 		;
				MOVLW 	3FH 		;Configura el puerto A como entrada
				MOVWF 	TRISA		
							 		;Se coloca un 0 en el registro W
				CLRF 	TRISC 		; Se configura al puerto PORTB como puerto de salida
				BCF 	STATUS,RP0 	;Regresa al banco cero
LOOP:			;Modo de direccionamiento indexado
				MOVF 	PORTA,W		; W <- (PORTA)
				ANDLW	0x07		; 
				ADDWF	PCL,F
				GOTO 	CERO		;PC + 0
				GOTO	UNO			;PC * 1
				GOTO	DOS			;PC * 2
				GOTO	TRES		;PC + 3
				GOTO	CERO		;PC + 4
				GOTO 	CERO  		;PC + 5
				GOTO	CERO    	;PC + 6
				GOTO	CERO		;PC + 7


CERO:			
				CLRF	PORTC
				GOTO 	LOOP
UNO:
				MOVLW 	B'00000001'
				MOVWF 	PORTC
				MOVLW	D'4'
				MOVWF	CTE2
				CALL  	RETARDO
				CLRF  	PORTC
				MOVLW	D'100'
				MOVWF	CTE2
				CALL  	RETARDO
				GOTO 	LOOP
DOS:
				MOVLW B'00000001'
				MOVWF PORTC
				MOVLW	D'7'
				MOVWF	CTE2
				CALL  RETARDO
				CLRF  PORTC
				MOVLW	D'100'
				MOVWF	CTE2
				CALL  RETARDO
				GOTO LOOP
TRES:
				MOVLW B'00000001'
				MOVWF PORTC
				MOVLW	D'10'
				MOVWF	CTE2
				CALL  RETARDO
				CLRF  PORTC
				MOVLW	D'100'
				MOVWF	CTE2
				CALL  RETARDO
				GOTO LOOP

;20 ms -> CT2 = 100
;2 ms ->	CT2 = 10
;1.5 ms  -> CTE2 = 7
;1 ms  -> CTE = 5
