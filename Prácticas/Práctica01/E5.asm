PROCESSOR 16f877
INCLUDE <p16f877.inc>

K	EQU	H'20'
	ORG	0
	GOTO INICIO
	ORG	5
INICIO:		MOVLW	0X00	;W = 0x00 
			MOVWF	K		;K = W	
SERIE1:		INCF	K		;K++
			MOVLW	0X05	;W = 0X05
			SUBWF	K,0		;W = K - W (0X05)		
			BTFSS	STATUS,2;Verifica si la operación 0
			GOTO 	SERIE1
SERIE2:		INCF	K		;K++
			MOVLW 	0X19	;W = 0X19
			SUBWF	K,0		;W = K - W (0X19)
			BTFSS	STATUS,2;Verifica si la operación 0
			GOTO	SERIE2
			MOVLW	0X20	;W = 0X20
			MOVWF	K		;W = K
			GOTO	INICIO	
			END