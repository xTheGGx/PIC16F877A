    PROCESSOR 16F877
    #include <p16f877.inc>

    ; Definiciones de registros y constantes
    CONTADOR_T0 EQU 0x20
    CONTADOR_T1 EQU 0x21
    CONTADOR_T2 EQU 0x22
    RESULTADO_AD0 EQU 0x23
    RESULTADO_AD1 EQU 0x24
    RESULTADO_AD2 EQU 0x25
	COUNTER		EQU	0X26

    ; Vectores de interrupción
    ORG 0
    GOTO INICIO

    ORG 4
    GOTO INTERRUPCIONES

    ; Configuración inicial
INICIO:
    ; Configuración de puertos y temporizadores
    BSF STATUS, RP0         ; Banco 1
    BCF STATUS, RP1
    CLRF TRISB              ; PORTB como salida
    CLRF TRISC              ; PORTC como salida
    CLRF TRISD              ; PORTD como salida
    BSF PIE1, TMR1IE        ; Habilitar interrupciones de TIMER1
    BSF PIE1, TMR2IE        ; Habilitar interrupciones de TIMER2
    MOVLW 0xFF
    MOVWF PR2               ; Configurar periodo de TIMER2
    MOVLW B'00000111'
    MOVWF OPTION_REG        ; Configurar prescaler para TIMER0
    BCF STATUS, RP0         ; Banco 0
    MOVLW B'00110001'
    MOVWF T1CON             ; Configurar TIMER1
    MOVLW B'01111111'
    MOVWF T2CON             ; Configurar TIMER2
    BSF INTCON, T0IE        ; Habilitar interrupciones de TIMER0
    BSF INTCON, PEIE        ; Habilitar interrupciones periféricas
    BSF INTCON, GIE         ; Habilitar interrupciones globales

    ; Configuración del A/D
    BSF STATUS, RP0         ; Banco 1
    MOVLW 0x00
    MOVWF ADCON1            ; Configurar todas las entradas AN como analógicas
    BCF STATUS, RP0         ; Banco 0

    ; Inicializar variables y puertos
    CLRF PORTA              ; Limpiar PORTA
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF CONTADOR_T0
    CLRF CONTADOR_T1
    CLRF CONTADOR_T2
    BCF INTCON, T0IF        ; Limpiar bandera de interrupción de TIMER0
    BCF PIR1, TMR1IF        ; Limpiar bandera de interrupción de TIMER1
    BCF PIR1, TMR2IF        ; Limpiar bandera de interrupción de TIMER2
    GOTO $                  ; Bucle infinito

    ; Rutina de interrupciones
INTERRUPCIONES:
    BTFSS INTCON, T0IF
    GOTO REVISA_TIMER1
    BTFSS PIR1, TMR1IF
    GOTO REVISA_TIMER2
    BTFSS PIR1, TMR2IF
    GOTO SAL_INT

    ; Manejo de interrupciones para TIMER0
    INCF CONTADOR_T0
    MOVLW D'60'
    SUBWF CONTADOR_T0, W
    BTFSS STATUS, Z
    GOTO SAL_INT_T0
    CALL LEER_ADC_AN1
    MOVF RESULTADO_AD0, W
    MOVWF PORTB              ; Desplegar valor de AN1 en PORTB
    CLRF CONTADOR_T0
    BCF INTCON, T0IF         ; Limpiar bandera de interrupción de TIMER0
    GOTO SAL_INT

REVISA_TIMER1:
    ; Manejo de interrupciones para TIMER1
    INCF CONTADOR_T1
    MOVLW D'120'
    SUBWF CONTADOR_T1, W
    BTFSS STATUS, Z
    GOTO SAL_INT_T1
    CALL LEER_ADC_AN2
    MOVF RESULTADO_AD1, W
    MOVWF PORTC              ; Desplegar valor de AN2 en PORTC
    CLRF CONTADOR_T1
    BCF PIR1, TMR1IF         ; Limpiar bandera de interrupción de TIMER1
    GOTO SAL_INT

REVISA_TIMER2:
    ; Manejo de interrupciones para TIMER2
    INCF CONTADOR_T2
    MOVLW D'180'
    SUBWF CONTADOR_T2, W
    BTFSS STATUS, Z
    GOTO SAL_INT_T2
    CALL LEER_ADC_AN3
    MOVF RESULTADO_AD2, W
    MOVWF PORTD              ; Desplegar valor de AN3 en PORTD
    CLRF CONTADOR_T2
    BCF PIR1, TMR2IF         ; Limpiar bandera de interrupción de TIMER2
    GOTO SAL_INT

SAL_INT:
    RETFIE

SAL_INT_T0:
    BCF INTCON, T0IF
    RETFIE

SAL_INT_T1:
    BCF PIR1, TMR1IF
    RETFIE

SAL_INT_T2:
    BCF PIR1, TMR2IF
    RETFIE

    ; Subrutina para leer el valor de ADC del canal AN1
LEER_ADC_AN1:
    BSF STATUS, RP0
    MOVLW B'11000001'       ; Configura canal AN1, ADCS0 y ADON
    MOVWF ADCON0
    BCF STATUS, RP0
    BSF ADCON0, GO          ; Inicia la conversión A/D
    CALL RETARDO_20us
ESPERA_ADC_AN1:
    BTFSC ADCON0, GO        ; Espera a que termine la conversión
    GOTO ESPERA_ADC_AN1
    MOVF ADRESH, W
    MOVWF RESULTADO_AD0     ; Guarda el resultado
    RETURN

    ; Subrutina para leer el valor de ADC del canal AN2
LEER_ADC_AN2:
    BSF STATUS, RP0
    MOVLW B'11001001'       ; Configura canal AN2, ADCS0 y ADON
    MOVWF ADCON0
    BCF STATUS, RP0
    BSF ADCON0, GO          ; Inicia la conversión A/D
    CALL RETARDO_20us
ESPERA_ADC_AN2:
    BTFSC ADCON0, GO        ; Espera a que termine la conversión
    GOTO ESPERA_ADC_AN2
    MOVF ADRESH, W
    MOVWF RESULTADO_AD1     ; Guarda el resultado
    RETURN

    ; Subrutina para leer el valor de ADC del canal AN3
LEER_ADC_AN3:
    BSF STATUS, RP0
    MOVLW B'11010001'       ; Configura canal AN3, ADCS0 y ADON
    MOVWF ADCON0
    BCF STATUS, RP0
    BSF ADCON0, GO          ; Inicia la conversión A/D
    CALL RETARDO_20us
ESPERA_ADC_AN3:
    BTFSC ADCON0, GO        ; Espera a que termine la conversión
    GOTO ESPERA_ADC_AN3
    MOVF ADRESH, W
    MOVWF RESULTADO_AD2     ; Guarda el resultado
    RETURN

    ; Subrutina de retardo de 20 microsegundos
RETARDO_20us:
    MOVLW D'40'
	MOVWF	COUNTER
RETARDO_LOOP:
    NOP
    DECFSZ COUNTER, F
    GOTO RETARDO_LOOP
    RETURN

    ENDa
