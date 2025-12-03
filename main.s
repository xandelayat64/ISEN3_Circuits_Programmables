
; Observations à l'oscilloscope:
; On observer un signal de période 20us, 10us état haut, 10us état bas

PROCESSOR 18F25K40
#include <xc.inc>

; LED_MATRIX = RB5

; Configuration =============================================================================
config FEXTOSC = OFF
config RSTOSC  = HFINTOSC_64MHZ
config WDTE    = OFF

; Variables RAM =============================================================================
PSECT udata_acs


; Code programme ============================================================================
PSECT code, abs

; Vecteur de reset ==========================================================================
org 0x000
    goto init

; Vecteur d'interruption haute priorité =====================================================
org 0x008
    goto High_ISR

; Vecteur d'interruption basse priorité =====================================================
org 0x018
    goto Low_ISR

; Programme principal =======================================================================
org 0x100

init:
    ; Ports 
    banksel ANSELB
    clrf ANSELB          ; PORTB digital

    banksel TRISB
    bcf TRISB, 5, 1       ; RB5 en sortie

    banksel LATB
    bcf LATB, 5, 1        ; LED_MATRIX éteinte

    ; Timer2
    ; Fosc = 64 MHz -> Fosc/4 = 16 MHz
    ; Pour 10 us -> 16MHz * 10us = 160 cycles soit PR2 = 159

    banksel T2CLKCON
    movlw 0b00000001      ; Clock = Fosc/4
    movwf T2CLKCON, 1

    banksel T2PR
    movlw 159
    movwf T2PR, 1

    banksel T2CON
    movlw 0b10000000      ; TMR2ON=1, prescaler=1:1, postscaler=1:1
    movwf T2CON, 1

    ; flag TMR2IF, mode off
    banksel PIR4
    bcf PIR4, 1, 1

    ; Interruptions =========================================================================
    ; activation des interruptions
    banksel INTCON
    bsf INTCON, 7, 1      ; GIE = 1
    bsf INTCON, 6, 1      ; PEIE = 1

    ; activer la priorité des interruptions
    banksel INTCON
    bcf INTCON, 5, 1        ; IPEN = 1

    banksel IPR4
    bsf IPR4, 1, 1        ; TMR2IP = 1 (haute priorité)

    banksel PIE4
    bsf PIE4, 1, 1        ; TMR2IE = 1

    banksel 0

; Boucle principale =============================================================================
loop:
    goto loop

; Routines d'intteruption =======================================================================
High_ISR:
    ; Vérifier si Timer2 a réalisé l'interruption
    banksel PIR4
    btfss PIR4, 1, 1
    retfie                ; si ce n’est pas TMR2IF, sortir

    ; flag, mode off
    bcf PIR4, 1, 1

    ; désactiver LED_MATRIX (soit RB5)
    banksel LATB
    btg LATB, 5, 1

    banksel 0
    retfie

Low_ISR:
    retfie

end
