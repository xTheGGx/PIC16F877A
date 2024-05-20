	include <p16f877.inc>

	CBLOCK 0X20
		VALOR
		VALOR1
		VALOR2
		AUX
		CONTADOR
		INDEX
		UNIDADES
		DECENAS
		CENTENAS
		ENTRADA
		FLAG
		FLAGMENU
		FLAGBIN
		FLAGHEX
		FLAGDECI
		FLAGTEMP
    	RESU                 ; PASAMOS EL VALOR DE ADRESH A E
    	U 
    	T
    	M
    	L
     	L1
    	ZA
		H
		X
		HA
		HB
		
		
		TEM
	ENDC

#DEFINE		RS		PORTC,1
#DEFINE		E		PORTC,0

	ORG		0	
	GOTO	INICIO
	ORG		5

INICIO:
			CLRF	PORTA
			CLRF	PORTB
			BSF 	STATUS,RP0
			BCF 	STATUS,RP1
			MOVLW	0X00	
			MOVWF	ADCON1			;Congigurar entradas anal�gicas
			CLRF	TRISD			;Configura puerto D como salida
			MOVLW	0XFF
			MOVWF	TRISB
			CLRF	TRISC
			BCF		STATUS,5
			CALL	INICIA_LCD
			MOVLW	0X80
			CALL	COMANDO

REDO:
			;CALL	BORRAR_DISPLAY
			CLRF	FLAG
			CLRF	FLAGMENU
			CLRF	FLAGBIN
			CLRF	CONTADOR
			CLRF	UNIDADES
			CLRF	DECENAS
			CLRF	CENTENAS
			CLRF	ENTRADA
			CLRF	AUX
			
MAIN:		;Modo de direccionamiento indexado
			BTFSS	FLAGMENU,0
			CALL	MSG_BIENVENIDA
			BSF		FLAGMENU,0
			MOVF	PORTB,W
			ANDLW	0X07
			ADDWF	PCL,F
			GOTO	CERO
			GOTO	ONE
			GOTO	TWO
			GOTO	THREE
			GOTO	FOUR
			GOTO	FIVE
			GOTO 	MAIN
			GOTO 	MAIN
;BINARIO
CERO:
			CALL	CONVERTIDOR
		    ; Inicializar la pantalla LCD para mostrar el valor en binario
		    ;CALL 	BORRAR_DISPLAY
		    ;MOVLW 	0X80
		    ;CALL 	COMANDO
		    ; Mostrar el valor binario
		    MOVLW 	D'8'                 ; N�mero de bits a mostrar
		    MOVWF 	CONTADOR
			BTFSS	FLAGBIN,0
			CALL	MSG_BIN
			BSF		FLAGBIN,0
			MOVLW	0XC0
			CALL	COMANDO
MOSTRAR_BITS:
		    RLF 	ENTRADA, F		         ; Desplazar el bit m�s significativo al Carry
		    BTFSC 	STATUS, C
		    MOVLW 	'1'
		    BTFSS 	STATUS, C
		    MOVLW 	'0'
		    CALL 	DATOS
		    DECFSZ 	CONTADOR, F
		    GOTO 	MOSTRAR_BITS
			CALL	RET2S
			CLRF	FLAGMENU
			CLRF	FLAGBIN
			GOTO	MAIN
;DECIMAL
ONE:
			CALL 	CONVERTIDOR			;W <-- ENTRADA DEL CONVERTIDOR ANALOGICO
			BTFSS	FLAG,0				;CHECAMOS BANDERA ANTES DE IMPRIMIR EL MENSAJE
			CALL	MSG_DECI			;SI BANDERA ACTIVA NO IMPRIME MSG
			BSF		FLAG,0
			MOVFW	PORTB
			SUBLW	0X01
			BTFSC	STATUS,Z
			GOTO	TWO
			CALL	RET2S
			GOTO	REDO
;HEXADECIMAL
TWO:
			CALL	CONVERTIDOR
			CALL	CHA
			CALL	MSG_HEXA
			CALL	RET2S
			GOTO	REDO
;VOLTAJE
THREE:
			CALL 	CONVERTIDOR
			CALL	CHD
			;CALL	BORRAR_DISPLAY
			CALL	MSG_VOLT
			CALL	RET2S
			GOTO 	REDO
;TEMPERATURA
FOUR:
			CALL 	CONVERTIDOR_TEMP
			CALL	BORRAR_DISPLAY
			CALL	RET100MS
			GOTO	REDO
;BATERIA
FIVE:
			CALL 	CONVERTIDOR
			CALL	BORRAR_DISPLAY
			CALL	RET100MS
			GOTO 	REDO

CONVERTIDOR:
			MOVLW	B'11001101'
			MOVWF	ADCON0
			CLRF	PORTB
ESPERA:		
			CALL	RET200
			BTFSC	ADCON0,2		;Pregunta por registro GO/DONE
			GOTO	ESPERA
			MOVFW	ADRESH			;W = ADRESH
			MOVWF	ENTRADA			;ENTRADA = W
			RETURN
			
CONVERTIDOR_TEMP:
			MOVLW	B'11000101'
			MOVWF	ADCON0
			CLRF	PORTB
ESPERA2:	
			CALL	RET200
			BTFSC	ADCON0,2		;Pregunta por registro GO/DONE
			GOTO	ESPERA2
			RETURN
			
; CONVERSI�N DE HEXA A DECIMAL PARA EL VOLTIMETRO
CHD
    MOVWF RESU                 ; PASAMOS EL VALOR DE ADRESH A E
    MOVLW H'00'             ; PASAMOS UN CERO PARA INICIALIZAR LOS CONTADORES
    MOVWF U 
    MOVWF T
    MOVWF M
    MOVWF L
    MOVWF L1
    MOVWF ZA
LOOP1
    MOVLW H'33'             ; N�MERO A RESTAR 51 DECIMAL
    SUBWF RESU,0               ; W = ADRESH - 33H
    BTFSS STATUS, H'00'     ; COMPRUEBA SI EL RESULTADO ES POSITIVO
    GOTO CONF               ; SALTA SI FUE NEGATIVO Y PASA A LOS DECIMALES
    MOVWF RESU                 ; GUARDA EL RESULTADO DE LA RESTA
    INCF U,1                ; INCREMENTA LA PARTE ENTERA
    GOTO LOOP1              ; REGRESA A RESTAR
CONF
    MOVF RESU,W                ; W = E
    MOVWF ZA                ; ZA = E
    CALL MULTIPLICACION
LOOP2
    MOVLW H'33'             ; N�MERO A RESTAR 51 DECIMAL
    SUBWF RESU,0               ; W = E - W
    BTFSS STATUS, H'00'     ; COMPRUEBA SI EL RESULTADO ES POSITIVO
    GOTO LOOP3
REGRESO1
    MOVWF RESU                 ; GUARDA EL RESULTADO DE LA RESTA
    INCF L,1                ; INCREMENTA LA PARTE DECIMAL
    GOTO LOOP2              ; REGRESA A RESTAR
LOOP3
    MOVWF ZA                ; GUARDA EL RESULTADO DE LA RESTA
    MOVLW H'01'             ; W = 1
    SUBWF T,0               ; W = T - 1
    BTFSS STATUS,H'00'      ; COMPRUEBA EL RESULTADO DE LA RESTA
    GOTO LOOP4 
    MOVWF T
    MOVF ZA, 0
    GOTO REGRESO1
LOOP4
    MOVLW H'00'             ; LIMPIAMOS EL REGISTRO M
    MOVWF M
    MOVF RESU,W                ; W = E
    MOVWF ZA                ; ZA = E
    CALL MULTIPLICACION
LOOP5
    MOVLW H'33'             ; N�MERO A RESTAR 51 DECIMAL
    SUBWF RESU,0               ; W = E - W
    BTFSS STATUS, H'00'     ; COMPRUEBA SI EL RESULTADO ES POSITIVO
    GOTO LOOP6
RET
    MOVWF RESU                 ; GUARDA EL RESULTADO DE LA RESTA
    INCF L1,1               ; INCREMENTA LA PARTE DECIMAL
    GOTO LOOP5              ; REGRESA A RESTAR
LOOP6
    MOVWF ZA                ; GUARDA EL RESULTADO DE LA RESTA
    MOVLW H'01'             ; W = 1
    SUBWF T,0               ; W = T - 1
    BTFSS STATUS,H'02'      ; COMPRUEBA EL RESULTADO DE LA RESTA
    GOTO LOOP7              ; SI ES 
    MOVWF T
    MOVF ZA, 0
    GOTO RET
LOOP7                       ; REALIZA LA CONVERSI�N A ASCII
    MOVLW H'30'
    ADDWF U,1
    MOVLW H'30'
    ADDWF L,1
    MOVLW H'30'
    ADDWF L1,1
    RETURN
; MULTIPLICACI�N
MULTIPLICACION
    MOVF ZA,W               ; ES EL VALOR DEL RESIDUO QUE DEBEMOS DE MULTIPLICAR
    ADDWF RESU,1               ; E = E + ZA
    BTFSC STATUS, H'00'     ; REVISA SI HUBO ALG�N DESBORDAMIENTO
    CALL NEGATIVO           ; SI HUBO DESBORDAMIENTO SALTA
    INCF M,1                ; INCREMENTA PARA EL CONTADOR DE LA MULTIPLICACI�N
    MOVLW X                 ; W = 9
    XORWF M,0               ; AND ENTRE  W Y X
    BTFSS STATUS, H'02'     ; COMPRUEBA LA BANDERA DE CERO PARA SABER SI YA SE MULTIPLIC� POR 10
    GOTO MULTIPLICACION     ; SIGNIFICA QUE A�N NO MULTIPLIC� POR 10
    RETURN

NEGATIVO
    MOVLW H'01'             ; W = 1
    ADDWF T,W               ; W = T + 1
    MOVWF T                 ; T = W
    RETURN                  ; REGRESA
; CONVERTIDOR HEX A ASCII
CHA
    MOVF ADRESH,W           ; MUEVE EL VALOR DEL ADRESH A W
    MOVWF TEM               ; PASA EL ADRESH A W
    MOVLW H'F0'
    ANDWF TEM,1             ; ELIMINAMOS LA PARTE BAJA
    SWAPF TEM,0
    MOVWF TEM
    CALL COMP
    MOVWF HA

    MOVF ADRESH,W           ; MUEVE EL VALOR DEL ADRESH A W
    MOVWF TEM               ; PASA EL ADRESH A W
    MOVLW H'0F'
    ANDWF TEM,1             ; ELIMINAMOS LA PARTE BAJA
    CALL COMP
    MOVWF HB
    RETURN
COMP
    MOVLW H'09'
    SUBWF TEM,0
    BTFSS STATUS, H'00'
    GOTO NUMERO
    BTFSC STATUS, H'02'
    GOTO NUMERO
    GOTO LETRA
REG
    RETURN
NUMERO
    MOVLW H'30'
    ADDWF TEM,0 
    GOTO REG
LETRA
    MOVLW H'37'
    ADDWF TEM,0
    GOTO REG    
;###########################################
;### RUTINAS DE MENSAJE SIN L�GICA  ########
;###########################################
MSG_DECI
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	CALL	RET200
	CALL	RET200
	MOVLW	A'D'
	CALL	DATOS
	MOVLW	A'E'
	CALL	DATOS
	MOVLW	A'C'
	CALL	DATOS
	MOVLW	A'I'
	CALL	DATOS
	MOVLW	A'M'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'L'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	0XC0
	CALL	COMANDO
	MOVFW	ENTRADA
	CALL	CONVER
	MOVFW	CENTENAS
	ADDLW	.48
	CALL	DATOS
	MOVFW   DECENAS
	ADDLW	.48
	CALL    DATOS
	MOVFW   UNIDADES
	ADDLW	.48
	CALL    DATOS

	RETURN
MSG_HEXA
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	CALL	RET200
	CALL	RET200
	MOVLW	A'H'
	CALL	DATOS
	MOVLW	A'E'
	CALL	DATOS
	MOVLW	A'X'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'D'
	CALL	DATOS
	MOVLW	A'E'
	CALL	DATOS
	MOVLW	A'C'
	CALL	DATOS
	MOVLW	A'I'
	CALL	DATOS
	MOVLW	A'M'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'L'
	CALL	DATOS
	MOVLW	0XC0
	CALL	COMANDO
    MOVF HA,W
    MOVWF PORTD
    CALL DATOS
    MOVF HB,W
    MOVWF PORTD
    CALL DATOS

	RETURN
MSG_BIN
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	MOVLW	A'B'
	CALL	DATOS
	MOVLW	A'I'
	CALL	DATOS
	MOVLW	A'N'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'R'
	CALL	DATOS
	MOVLW	A'I'
	CALL	DATOS
	MOVLW	A'O'
	CALL	DATOS

	RETURN

MSG_VOLT
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	MOVLW	A'V'
	CALL	DATOS
	MOVLW	A'O'
	CALL	DATOS
	MOVLW	A'L'
	CALL	DATOS
	MOVLW	A'T'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'J'
	CALL	DATOS
	MOVLW	A'E'
	CALL	DATOS
	MOVLW	0XC0
	CALL	COMANDO
    MOVF U,W
    MOVWF PORTD
    CALL DATOS
    MOVLW '.'
    MOVWF PORTD
    CALL DATOS
    MOVF L,W
    MOVWF PORTD
    CALL DATOS
    MOVF L1,W
    MOVWF PORTD
    CALL DATOS
    MOVLW 'V'
    MOVWF PORTD
    CALL DATOS

	RETURN

MSG_NEXT
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	MOVLW	A'P'
	CALL	DATOS
	MOVLW	A'R'
	CALL	DATOS
	MOVLW	A'E'
	CALL	DATOS
	MOVLW	A'S'
	CALL	DATOS
	MOVLW	A'S'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A'S'
	CALL	DATOS
	MOVLW	A'T'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'R'
	CALL	DATOS
	MOVLW	A'T'
	CALL	DATOS

	RETURN

MSG_BIENVENIDA
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'l'
	CALL	DATOS
	MOVLW	A'e'
	CALL	DATOS
	MOVLW	A'x'
	CALL	DATOS
	MOVLW	A'i'
	CALL	DATOS
	MOVLW	A's'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A'S'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	A'n'
	CALL	DATOS
	MOVLW	A'c'
	CALL	DATOS
	MOVLW	A'h'
	CALL	DATOS
	MOVLW	A'e'
	CALL	DATOS
	MOVLW	A'z'
	CALL	DATOS

	MOVLW	0XC0
	CALL	COMANDO
	MOVLW	A'F'
	CALL	DATOS
	MOVLW	A'.'
	CALL	DATOS
	MOVLW	A'I'
	CALL	DATOS
	MOVLW	A'.'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A'U'
	CALL	DATOS
	MOVLW	A'N'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'M'
	CALL	DATOS

	RETURN
MSG_JUEGO
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	CALL	RET200
	CALL	RET200
	MOVLW	A'P'
	CALL	DATOS
	MOVLW	A'r'
	CALL	DATOS
	MOVLW	A'e'
	CALL	DATOS
	MOVLW	A's'
	CALL	DATOS
	MOVLW	A'i'
	CALL	DATOS
	MOVLW	A'o'
	CALL	DATOS
	MOVLW	A'n'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	0XC0
	CALL	COMANDO
	MOVLW	A'S'
	CALL	DATOS
	MOVLW	A'T'
	CALL	DATOS
	MOVLW	A'A'
	CALL	DATOS
	MOVLW	A'R'
	CALL	DATOS
	MOVLW	A'T'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A'p'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	A'r'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A'i'
	CALL	DATOS
	MOVLW	A'n'
	CALL	DATOS
	MOVLW	A'i'
	CALL	DATOS
	MOVLW	A't'
	CALL	DATOS
	RETURN
;###########################################
;### RUTINAS DE CONFIG DE LCD   ############
;###########################################
INICIA_LCD	
	MOVLW	0X30
	CALL	COMANDO
	CALL	RET100MS
	MOVLW	0X30
	CALL	COMANDO
	CALL	RET100MS
	MOVLW	0X38		;8 BITS = 2 RENGLONES
	CALL	COMANDO
	MOVLW	0X0C		;DISPLAY: Activa pantalla, desactiva cursor y parpadeo
	CALL	COMANDO
	MOVLW	0X01		;BORRAR PANTALLA
	CALL	COMANDO
	MOVLW	0X06		;SIN INCREMENTO
	CALL	COMANDO
	MOVLW	0X02
	CALL	COMANDO
	RETURN

COMANDO:
	MOVWF	PORTD
	CALL	RET200
	BCF		RS
	BSF		E
	CALL	RET200
	BCF		E
	RETURN

DATOS:
	MOVWF	PORTD
	CALL	RET200
	BSF		RS
	BSF		E
	CALL	RET200
	BCF		E
	CALL	RET200
	CALL	RET200
	RETURN

BORRAR_DISPLAY:
	MOVLW	0X01
	CALL	COMANDO
	RETURN
;###########################################
;### RUTINAS HEXA --> ASSCII  ##############
;###########################################
CONVER:
		MOVWF	AUX
CENTENAS_LOOP:
        MOVLW   .100            ; Valor para restar (100 decimal)
        SUBWF   AUX, W         ; Intenta restar 100
        BTFSS   STATUS, C       ; Si hay carry, el resultado es negativo, salta
		GOTO    DECENAS_LOOP    ; Procede a convertir decenas si no se puede restar m�s centenas
        INCF    CENTENAS, F     ; Incrementa las centenas
        MOVWF   AUX            ; Actualiza TEMP con el nuevo valor
        GOTO    CENTENAS_LOOP   ; Intenta restar 100 nuevamente

; Convertir a Decenas
DECENAS_LOOP:
        MOVLW   .10             ; Valor para restar (10 decimal)
        SUBWF   AUX, W         ; Intenta restar 10
        BTFSS   STATUS, C       ; Si hay carry, el resultado es negativo, salta
        GOTO    UNIDADES_LOOP   ; Procede a convertir unidades si no se puede restar m�s decenas
        INCF    DECENAS, F      ; Incrementa las decenas
        MOVWF   AUX            ; Actualiza TEMP con el nuevo valor
        GOTO    DECENAS_LOOP    ; Intenta restar 10 nuevamente

; Ajuste de Unidades
UNIDADES_LOOP:
        MOVF    AUX, W         ; Mueve el valor restante a W
        MOVWF   UNIDADES        ; Almacena el valor final como unidades

    RETURN


;###########################################
;### RUTINAS DE RETARDO  ###################
;###########################################
RET200
	MOVLW	0X02
	MOVWF	VALOR1
LOOP
	MOVLW	.164
	MOVWF	VALOR
LOOP11
	DECFSZ	VALOR,1
	GOTO	LOOP11
	DECFSZ	VALOR1,1
	GOTO	LOOP
	RETURN

RET100MS
	MOVLW	D'3'
	MOVWF	VALOR
TRES
	MOVLW	0XFF
	MOVWF	VALOR1
DOS
	MOVLW	0XFF
	MOVWF	VALOR2
UNO	
	DECFSZ	VALOR2
	GOTO	UNO
	DECFSZ	VALOR1
	GOTO	DOS
	DECFSZ	VALOR
	GOTO	TRES
	RETURN

RET2S
	MOVLW	0X1F
	MOVWF	VALOR
TRESA
	MOVLW	0XFF
	MOVWF	VALOR1
DOSA
	MOVLW	0XFF
	MOVWF	VALOR2
UNOA	
	DECFSZ	VALOR2
	GOTO	UNOA
	DECFSZ	VALOR1
	GOTO	DOSA
	DECFSZ	VALOR
	GOTO	TRESA
	RETURN

	END

