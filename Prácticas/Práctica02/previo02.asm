processor 16f8777a
include <p16f877.inc>

			org 0
			goto inicio
			
			org 5

inicio:		movlw 	0x20		;w <-- 0x20
			movwf	FSR			;Inicializa el puntero
next:		clrf	INDF		;Borra el contenido de lo que apunta FSR, (INDF) = 0
			incf	FSR,f		;incrementa el apuntador, FSR = FSR + 1
			btfss	FSR,4		;Ya hemos terminado?
			goto 	next		;no, ve a borrar la siguiente localidad
			goto 	inicio		;si, ve a la etiqueta "inicio"
			end