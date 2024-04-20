PROCESSOR	16F877
INCLUDE	<p16f877.inc>

K	EQU		H'20'		;se crea la variable K (dirección de memoria adjudicada a la etiqueta K)
	
	ORG		0
	GOTO	INICIO

	ORG		5

INICIO:		MOVLW	0X01		;W = 0X01
			MOVWF	K			;K = W
SERIE: 		RLF 	K,1			;Rotación sobre K. RLF	f,d	registro f es rotado on bit ala izquierda si d es 0 el resultado se guarda en 'w', si es 1 se guarda en el propio registro
			BTFSS	K,7			
			GOTO 	SERIE	
			GOTO	INICIO
			END
	