processor 16f877 					;Indica la versión de procesador
include <p16f877.inc> 				;Incluye la librería de la versión del procesador
				valor1 equ h'21'
valor1 equ h'21'
valor2 equ h'22'
resultado equ h'23'
				ORG 0H 				;Carga al vector de RESET la dirección de inicio
				GOTO INICIO 		;Nos movemos a la etiqueta inicio
				ORG 05H 			;Dirección de inicio del programa del usuario

INICIO: 		
				movfw	valor1
				CLRF	STATUS
				addwf	valor2,0
				movwf	resultado


				END				;Fin de programa 
