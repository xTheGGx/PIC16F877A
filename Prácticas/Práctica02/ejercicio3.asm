INCLUDE <p16f877a.inc>

CONT 	 EQU	0X30 		; contador para loop externo
AUX1	 EQU	0X31 		; auxiliar para el SWAP
AUX2 	 EQU	0X32 		; auxiliar para el SWAP
FLAG	 EQU	0X33	; bandera terminar bubble sort
		
		 ORG 0
		 GOTO INICIO
 		 ORG 5

INICIO:
		MOVLW 	0x20
		MOVWF 	CONT 		; CONTADOR = 0x20
		MOVLW 	0x01 		; W = 1
		MOVWF 	FLAG 		; BANDERA = 1
ITERACION:
		BTFSS 	FLAG,0 		; checa si no hubo cambios
		GOTO 	FINAL 		; si no hubo cambios va al final
		BTFSC 	CONT,4 		; checa si se llego al máximo del contador.
		GOTO 	FINAL 		; Va a final - limite bubble sort.
		INCF 	CONT 		; CONTADOR ++
		MOVLW 	0x20 		; W = 0x20
		MOVWF 	FSR 		; FSR <- (W) = 0x20
		MOVLW 	0x00 		; W = 0
		MOVWF 	FLAG 		; BANDERA = 0
LOOP:
		MOVF 	INDF,W 		; W <- INDF.
		INCF 	FSR 		; FSR ++
		BTFSC 	FSR,4 		; FSR[4]
		goto 	ITERACION 	; siguiente iteración.
		SUBWF 	INDF,0 		; W = INDF - W; si es negativo, C=0, cambio
		BTFSC 	STATUS,C 	;
		GOTO 	LOOP 		;
SWAP:
		MOVLW 	0x01 		; W = 1
		MOVWF 	FLAG 		; bandera registra cambio
		MOVF 	INDF,W 		; W = FSR(+)
		MOVWF 	AUX1 		; AUX1 = W
		DECF 	FSR 		; FSR --
		MOVF 	INDF,W 		; W = FSR(-)
		MOVWF 	AUX2 		; AUX2 = W
		MOVF 	AUX1,W 		; W = AUX1
		MOVWF 	INDF 		; INDF(-) = AUX1
		INCF 	FSR 		; FSR ++
		MOVF 	AUX2,W 		; W = AUX2
		MOVWF 	INDF 		; INDF(+) = AUX2
		GOTO	LOOP  		; va a checar el siguiente.
FINAL:
		GOTO	$	
END