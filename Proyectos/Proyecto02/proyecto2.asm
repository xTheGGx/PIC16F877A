	include <p16f877.inc>

	CBLOCK 0X20
		VALOR
		VALOR1
		VALOR2
		FLAG1
		FLAG2
		FLAG3
		PLAYERS
		START_BUTTON
		FINISH_BUTTON
		NUM_JUGADORES
		AUX
		CONTADOR
		P1_CONT
		P2_CONT
		P3_CONT
		P4_CONT
		INDEX
		WINNER
		WINNER_ID
		UNIDADES
		DECENAS
		CENTENAS
	ENDC

#DEFINE		RS		PORTA,0
#DEFINE		E		PORTA,1

	ORG		0	
	GOTO	INICIO
	ORG		5

INICIO:
	CLRF	PORTA
	CLRF	PORTB
	CLRF	PORTC
	BSF		STATUS,5
	BCF		STATUS,6
	CLRF	TRISB
	MOVLW	0X07
	MOVWF	ADCON1
	MOVLW	B'00001100'		;BIT 0 Y 1 COMO SALIDA, 2 Y 3 COMO ENTRADA
	MOVWF	TRISA
	MOVLW	B'11100000'		;BIT 7, 6 Y 5 COMO ENTRADA
	MOVWF	TRISD
	MOVLW	B'00000000'
	MOVWF	TRISC

	BCF		STATUS,5
	CALL	INICIA_LCD
	MOVLW	0X80
	CALL	COMANDO
	BCF		FLAG1,0
	BCF		FLAG2,0
	BCF		FLAG3,0
	
MAIN:
	CLRF	PORTA
	CLRF	PORTB
	CLRF	PORTD
	BCF		FLAG2,0			;FLAG2 <- 0
	BTFSS	FLAG1,0			;FLAG1 = 1?
	CALL	MSG_BIENVENIDA	;NO -> IMPRIME MENSAJE DE BIENVENIDA
	BSF		FLAG1,0			;SI -> FLAG1 = 1
	CALL	CHECK_PLAYERS	;VERIFICA EL N?MERO DE JUGADORES
	MOVFW	NUM_JUGADORES
	MOVWF	PLAYERS
	MOVFW	PORTA			;W <-- PORTA
	MOVWF	START_BUTTON
	CALL	RET100MS		;ESPERA POR SI SE DEJA PRESIONADO EL BOTTON
	CALL	RET100MS
	BTFSS	START_BUTTON,2	;PORTA(2) <-- BOTON DE INICIO
	GOTO 	MAIN
	GOTO	IN_GAME

IN_GAME	
	CLRF	CONTADOR
	CLRF	P1_CONT
	CLRF	P2_CONT
	CLRF	P3_CONT
	CLRF	P4_CONT
	CLRF	WINNER
	CLRF	WINNER_ID
	CLRF	PLAYERS
	BCF		FLAG3,0
	MOVLW	0X01
	MOVWF	INDEX			;REINICIAMOS INDICE, SETEADO EN 1

	BCF		FLAG1,0			;FLAG1 <- 0
	BTFSS	FLAG2,0			;FLAG2 = 1?
	CALL	MSG_JUEGO		;NO	-> IMPRIME MENSAJE DE JUEGO
	BSF		FLAG2,0			;SI -> FLAG2 = 1
	GOTO	CICLO
NEXT_PLAYER:
	CALL	SETSCORE		;GUARDAMOS LA PUNTUACI�N DEL JUGADOR UTILIZANDO EL INDICE Y EL CONTADOR
	INCF	INDEX,1			;APUNTAMOS EL INDICE AL SIGUIENTE JUGADOR
	BCF		FLAG3,0			;BANDERA DE MENSAJE EN RECORRIDO
	CALL	MSG_NEXT		;MANDA MENSAJE CON INSTRUCCIONES
CICLO:
	MOVFW	PORTA
	MOVWF	START_BUTTON
	BTFSS	START_BUTTON,2	;START = 1?
	GOTO	CICLO			;NO, ESPERA A QUE SE PRESIONE
RECORRIDO					;SI, COMIENZA EL RECORRIDO
	BTFSS	FLAG3,0			;FLAG3 = 1?
	CALL	MSG				;NO, IMPRIME MENSAJE DE RECORRIDO
	BSF		FLAG3,0			;SI, FLAG3 <- 1
	;DETECCI?N DE COLISIONES
	CALL	DETECTA
	;HEMOS TERMINADO?
	MOVFW	PORTA			
	MOVWF	FINISH_BUTTON
	BTFSS	FINISH_BUTTON,3	;FINISH = 1?
	GOTO	RECORRIDO		;NO, ESPERA A QUE TERMINE EL RECORRIDO
	;TERMINAMOS RECORRIDO, VERIFICAMOS JUGADORES RESTANTES
	DECF	NUM_JUGADORES,F	;NUM_JUGADORES = 0?
	MOVFW	NUM_JUGADORES
	SUBLW	0X00
	BTFSS	STATUS,Z		;NUM_JUGADORES = 0?
	GOTO	NEXT_PLAYER		;NO, EMPIEZA EL SIGUIENTE JUGADOR

	MOVFW	PLAYERS
	SUBLW	0X01	
	BTFSC	STATUS,Z		;HAY UN SOLO JUGADOR?
	CALL	SETSCORE		;SI

	CALL	MENOR			;SI, OBTIENE AL GANADOR
	CALL	GANADOR			;SI, IMPRIME MENSAJE CON EL GANADOR
	;FINISH PARA TERMINAR FLUJO
REP:
	MOVFW	PORTA			
	MOVWF	FINISH_BUTTON
	BTFSS	FINISH_BUTTON,3	;FINISH = 1?
	GOTO	REP
	GOTO	MAIN

MENOR:
    MOVFW   P1_CONT         ; Cargar P1_CONT en W
    MOVWF   WINNER           ; Establecer WINNER con el puntaje de P1
    MOVLW   0x01
    MOVWF   WINNER_ID        ; Establecer WINNER_ID a 1

    MOVLW   0X02
    SUBWF   PLAYERS,W        ;PLAYERS - 02
    BTFSC  	STATUS,C         ; PLAYERS < 02?
    GOTO    CHECK_P2		 ;NO, PLAYERS MAYOR O IGUAL A 02
    GOTO    END_MENOR        ;SI, TERMINA EL CHEQUEO

	; Comparar con P2_CONT
CHECK_P2:
    MOVFW    P2_CONT
    SUBWF   WINNER, W        ;WINNER - P2
    BTFSC   STATUS, C        ;P1_CONT < P2_CONT ?
	GOTO    UPDATE_P2		 ;SI,P2 ES MENOR O IGUAL A P1

    MOVLW   0X03
    SUBWF   PLAYERS,W        ;PLAYERS - 02
    BTFSC  STATUS,C         ; PLAYERS < 02?
    GOTO    CHECK_P3		 ;NO, PLAYERS MAYOR O IGUAL A 02
    GOTO    END_MENOR        ;SI, TERMINA EL CHEQUEO

UPDATE_P2:
    MOVFW   P2_CONT
    MOVWF   WINNER
    MOVLW   0x02
    MOVWF   WINNER_ID
    
    MOVLW   0X03
    SUBWF   PLAYERS,W        ;PLAYERS - 02
    BTFSC   STATUS,C         ; PLAYERS < 02?
    GOTO    CHECK_P3		 ;NO, PLAYERS MAYOR O IGUAL A 02
    GOTO    END_MENOR        ;SI, TERMINA EL CHEQUEO

						;SI, COMPARA 3
CHECK_P3:	
    MOVFW   P3_CONT
    SUBWF   WINNER,W       ;WINNER - P3
    BTFSC   STATUS,C		;WINNER < P3?
    GOTO    UPDATE_P3		;NO P3 ES MENOR O IGUAL A WINNER
                    		;SI WINNER ES MENOR

    MOVLW   0X04
    SUBWF   PLAYERS,W        ;PLAYERS - 03
    BTFSC   STATUS,C         ; PLAYERS < 03?
    GOTO    CHECK_P4		 ;NO, PLAYERS MAYOR O IGUAL A 03
    GOTO    END_MENOR        ;SI, TERMINA EL CHEQUEO


UPDATE_P3:
    MOVFW   P3_CONT
    MOVWF   WINNER
    MOVLW   0x03
    MOVWF   WINNER_ID
    
    MOVLW   0X04
    SUBWF   PLAYERS,W        ;PLAYERS - 03
    BTFSC  STATUS,C         ; PLAYERS < 03?
    GOTO    CHECK_P4		 ;NO, PLAYERS MAYOR O IGUAL A 03
    GOTO    END_MENOR        ;SI, TERMINA EL CHEQUEO

CHECK_P4:
    MOVFW   P4_CONT
    SUBWF   WINNER, W		;WINNER - P4
    BTFSC   STATUS,C		;WINNER < P4?
    GOTO    UPDATE_P4		;NO, P4 ES MENOR O IGUAL
    GOTO    END_MENOR		;SI, WINNER ES MENOR	

UPDATE_P4:
    MOVF    P4_CONT, W
    MOVWF   WINNER
    MOVLW   0x04
    MOVWF   WINNER_ID

END_MENOR:
    RETURN




DETECTA	
	;PORTD,5 ES NUESTRO BIT DE ENTRADA
	
	BTFSS   PORTD, 5		;AUX = 20H? 
	GOTO	CONTINUA		;NO, NO HAY COLISION
	INCF	CONTADOR,1		;SI, AUMENTAMOS CONTADOR
							;ACTIVAR ZUMBADOR
	BSF		PORTC,0			;ACTIVAR LED
	CALL	RET2S			;RETARDO_2S
							;DESACTIVAR ZUMBADOR
	BCF		PORTC,0			;DESACTIVAR LED
CONTINUA:
	RETURN

SETSCORE:
	MOVFW	INDEX		  ; W <- INDEX
	;MOVWF	AUX			  ; AUX <- W
	MOVLW   .1			  ; W <- 0X01
	SUBWF   INDEX, W	  ; AUX - W -> W: SI SON IGUALES BIT Z EN 1
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    S_UNO         ; 
	
	MOVLW   .2
	SUBWF   INDEX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    S_DOS         ; 
	
	MOVLW   .3
	SUBWF   INDEX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    S_TRES        ; 
	
	MOVLW   .4
	SUBWF   INDEX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    S_CUATRO      ; 
	
	RETURN


;###########################################
;### RUTINAS DE MENSAJE SIN L�GICA  ########
;###########################################
GANADOR:
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	MOVLW	A'J'
	CALL	DATOS
	MOVLW	A'u'
	CALL	DATOS
	MOVLW	A'g'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	A'd'
	CALL	DATOS
	MOVLW	A'o'
	CALL	DATOS
	MOVLW	A'r'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS

	MOVFW   WINNER_ID
	CALL    CONVER
	
	MOVFW   UNIDADES
	ADDLW	.48
	CALL    DATOS

	MOVLW	0XC0
	CALL	COMANDO

	MOVLW	A'G'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	A'n'
	CALL	DATOS
	MOVLW	A'a'
	CALL	DATOS
	MOVLW	A' '
	CALL	DATOS
	MOVLW	A'c'
	CALL	DATOS
	MOVLW	A'o'
	CALL	DATOS
	MOVLW	A'n'
	CALL	DATOS
	MOVLW	A' '
	CALL 	DATOS

	MOVFW   WINNER
	CALL    CONVER
	
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

MSG
	CALL	BORRAR_DISPLAY
	CALL	RET100MS
	CALL	RET100MS
	MOVLW	0X80
	CALL	COMANDO
	MOVLW	A'R'
	CALL	DATOS
	MOVLW	A'e'
	CALL	DATOS
	MOVLW	A'c'
	CALL	DATOS
	MOVLW	A'o'
	CALL	DATOS
	MOVLW	A'r'
	CALL	DATOS
	MOVLW	A'r'
	CALL	DATOS
	MOVLW	A'i'
	CALL	DATOS
	MOVLW	A'd'
	CALL	DATOS
	MOVLW	A'o'
	CALL	DATOS
	MOVLW	A'.'
	CALL	DATOS
	MOVLW	A'.'
	CALL	DATOS
	MOVLW	A'.'
	CALL	DATOS

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
	MOVLW	0X38
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
	MOVWF	PORTB
	CALL	RET200
	BCF		RS
	BSF		E
	CALL	RET200
	BCF		E
	RETURN

DATOS:
	MOVWF	PORTB
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
;### RUTINAS PARA #JUGADORES  ##############
;###########################################
CHECK_PLAYERS
	MOVFW	PORTD
	ANDLW	0XC0		  ;Mascara de bits, me quedo con bit 7 y 6 en w
	MOVWF	AUX

	MOVLW   0x00
	SUBWF   AUX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    UNO_P         ; Saltar si los bits son 00
	
	MOVLW   0x40
	SUBWF   AUX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    DOS_P         ; Saltar si los bits son 01
	
	MOVLW   0x80
	SUBWF   AUX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    TRES_P        ; Saltar si los bits son 10
	
	MOVLW   0xC0
	SUBWF   AUX, W
	BTFSC   STATUS, Z     ; Verificar el bit Zero
	CALL    CUATRO_P      ; Saltar si los bits son 11

	MOVFW	NUM_JUGADORES
	
	RETURN
;###########################################
;### RUTINAS DE ASIGNACI�N DE ERRORES   ####
;###########################################
S_UNO
	MOVFW	CONTADOR
	MOVWF	P1_CONT
	CLRF	CONTADOR		;REINICIAMOS CONTADOR
	RETURN
S_DOS
	MOVFW	CONTADOR
	MOVWF	P2_CONT
	CLRF	CONTADOR		;REINICIAMOS CONTADOR
	RETURN
S_TRES
	MOVFW	CONTADOR
	MOVWF	P3_CONT
	CLRF	CONTADOR		;REINICIAMOS CONTADOR
	RETURN
S_CUATRO	
	MOVFW	CONTADOR
	MOVWF	P4_CONT
	CLRF	CONTADOR		;REINICIAMOS CONTADOR
	RETURN
;###########################################
;### RUTINAS DE ASIG DE #JUGADORES  ########
;###########################################
UNO_P
	MOVLW	0X01
	MOVWF	NUM_JUGADORES
	RETURN
DOS_P
	MOVLW	0X02
	MOVWF	NUM_JUGADORES
	RETURN
TRES_P
	MOVLW	0X03
	MOVWF	NUM_JUGADORES
	RETURN
CUATRO_P	
	MOVLW	0X04
	MOVWF	NUM_JUGADORES
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
LOOP1
	DECFSZ	VALOR,1
	GOTO	LOOP1
	DECFSZ	VALOR1,1
	GOTO	LOOP
	RETURN

RET100MS
	MOVLW	0X03
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


