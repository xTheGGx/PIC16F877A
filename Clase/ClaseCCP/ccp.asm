processor 16f877
#include <16f877.inc>

ORG	0
GOTO	INICIO
ORG		5

INICIO		BSF		STATUS,0
			BCF		STATUS,1

			BCF		TRISC,1
			BCF		TRISC,2
			
			MOVLW	D'255'
			MOVWF	PR2
			BCF		STATUS,RP0
			MOVLW	B'00001100'
			MOVWF	CCP2CON
			MOVLW	B'00000111'
			MOVWF	T2CON
			MOVLW	D'120'
			MOVWF	CCPR2L
			GOTO	$

			END