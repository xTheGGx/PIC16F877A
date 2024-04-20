PROCESSOR 16f877 
#INCLUDE <p16f877.inc>

resultado equ H'40' 
ORG 0 
GOTO INICIO 
ORG 5 

INICIO: 
			MOVLW 	0x20 		;W <- 0x20
			MOVWF 	FSR			;FSR <- W = 0x20
			MOVF 	INDF,0		;W <- FSR (Valor de la localidad 0x20)
			MOVWF 	resultado	;W <- resultado W se vuelve el menor, yéndose a 0x40 
CHECK: 		INCF 	FSR			;El apuntador va a la siguiente localidad 
			BTFSC 	FSR,6		;Estamos en 0x40? 
			GOTO 	TERMINAR	;SI, ya terminamos de ver todo. Termina el programa 
			MOVF 	INDF,0		;NO, Lo que hay en la localidad actual se mueve a W 
			SUBWF 	resultado,0	; RES >= W? (resultado-W) 
			BTFSS 	STATUS,C	;Lo que hay en RES es mayor a W? 
			GOTO 	RES_MENOR	;NO, se va a MENOR 
			GOTO 	RES_MAYOR	;SI, se continúa el proceso 
RES_MENOR:						;Si RES es MENOR no se hace nada, ya es el menor hasta ese punto 
			GOTO 	CHECK 
RES_MAYOR:						;Si RES es MAYOR, existe un valor menor hasta ese punto, se actualiza 
			MOVF 	INDF,0 
			MOVWF 	resultado 
			GOTO 	CHECK 
TERMINAR: 	SLEEP
END