PROCESSOR	16F877
INCLUDE	<p16f877.inc>

J	EQU		H'26'		;se crea la variable J (dirección de memoria adjudicada a la etiqueta J)
K	EQU		H'27'		;se crea la variable K (dirección de memoria adjudicada a la etiqueta K)
C1	EQU		H'28'		;se crea la variable CL (dirección de memoria adjudicada a la etiqueta CL)
R1	EQU		H'29'		;se crea la variable RL (dirección de memoria adjudicada a la etiqueta RL)

	ORG		0
	GOTO	INICIO

	ORG		5

INICIO:		MOVF		J,W		;W = J
			ADDWF		K,0		;W = W + K
			MOVWF		R1		;RL = W
			BTFSS		STATUS,CL 
			GOTO		NO_UNO
ES_UNO:		MOVLW		1
			MOVWF		CL
			GOTO		INICIO
NO_UNO:		
			END
	