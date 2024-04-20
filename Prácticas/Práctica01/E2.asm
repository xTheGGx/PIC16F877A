PROCESSOR	16F877
INCLUDE	<p16f877.inc>

K	EQU		H'26'		;se crea la variable K (dirección de memoria adjudicada a la etiqueta K)
L	EQU		H'27'		;se crea la variable L (dirección de memoria adjudicada a la etiqueta L)
M	EQU		H'28'		;se crea la variable M (dirección de memoria adjudicada a la etiqueta M)

	ORG		0
	GOTO	INICIO

	ORG		5

INICIO:		MOVF		K,W		;W = K
			ADDWF		L,0		;W = W + L	
			MOVWF		M		;M = W
			GOTO		INICIO
			END
	