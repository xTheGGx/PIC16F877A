processor 16f877 					;Indica la versi�n de procesador
include <p16f877.inc> 				;Incluye la librer�a de la versi�n del procesador
				valor1 equ h'21'
valor1 equ h'21'
valor2 equ h'22'
resultado equ h'23'
				ORG 0H 				;Carga al vector de RESET la direcci�n de inicio
				GOTO INICIO 		;Nos movemos a la etiqueta inicio
				ORG 05H 			;Direcci�n de inicio del programa del usuario

INICIO: 		
				movfw	valor1
				CLRF	STATUS
				addwf	valor2,0
				movwf	resultado


				END				;Fin de programa 
