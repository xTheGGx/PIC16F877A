processor 16f877
include <p16f877.inc>

k	equ		h'26'		;se crea la variable k (dirección de memoria adjudicada a la etiqueta k)
l	equ		h'27'		;se crea la variable l (dirección de memoria adjudicada a la etiqueta l)

	org		0
	goto	inicio
	org		5

inicio:
	movlw	h'05'		;W = 0x05
	addwf	k,0			;w = w + k
	movwf	l			;l = w
	goto	inicio
	end
