PROCESSOR 16f877
INCLUDE <p16f877.inc>
		ORG 0
 		GOTO INICIO
		ORG 5
INICIO: BCF 	STATUS,RP1		;Borra el bit RP1 del registro STATUS
		BSF 	STATUS,RP0		;Se establece RP0 en el registro STATUS cambia al banco 1 de ram
		MOVLW 	0X20			;W = 0x20
		MOVWF 	FSR				;FSR = W = 0x20
LOOP: 	MOVLW 	0X5F			;W = 0x5F
		MOVWF 	INDF			;INDF = W = 0X5F ; INDF -> (FSR) [0x20] <- 0x5F
		INCF 	FSR				;(FSR)++
		BTFSS 	FSR,6			;Si FSR = X1XX XXXX (0x40), entonces termina el loop 
		GOTO 	LOOP			;Si FSR != X1XXX XXXX (0x40), repite el loop
		GOTO 	$				;Etiqueta: GOTO Etiqueta
		END	