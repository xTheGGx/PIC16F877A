;processor 16f877			
include <p16f877.inc>		;Libreria del microcontrolador

K		equ		h'26'		;Declara K = 0x26
l		equ		h'27'		;Cuando el ensamblador vea L lo cambiará por 0x27

		org		0			;Indica que la singuientes instrucciones se ensambla
		goto	inicio		;de la dirección 0x0000 de ROM
		org		5			;Salgo a la dirección de la etiqueta INICIO

inicio:
		movlw	h'05'		;W <-- 0x05
		addwf	k,0			;w <-- w + k
		movwf	l			;l <-- w
		goto	inicio
		end
