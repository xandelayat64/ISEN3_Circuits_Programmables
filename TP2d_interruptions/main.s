PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ======================================================================
config FEXTOSC = OFF
config RSTOSC  = HFINTOSC_64MHZ
config WDTE    = OFF

; Variables RAM =======================================================================
PSECT udata_acs

; Code programme ============================================================================
PSECT code, abs

org 0x000
    goto init

org 0x008
    goto High_ISR

org 0x018
    goto Low_ISR

; Variables ===============================================================================
ChenillardCount:   ds 1
LDM1Count:         ds 1
LedMask:           ds 1

; Programme principal ======================================================================
org 0x100

init:
    ; Configuration des éntrées et des sorties
    clrf ANSELB
    clrf TRISB
    clrf LATB

    clrf ANSELC
    bcf TRISC,6,1
    bcf LATC,6,1

    ; Initialisation variables
    movlw 0x01
    movwf LedMask
    clrf ChenillardCount
    clrf LDM1Count

; TIMER2 = 1 ms — haute priorité
    movlw 0x01
    movwf T2CLKCON,1

    movlw 0b00000101          ; 1:16 prescaler à 1 MHz
    movwf T2CON,1

    movlw low(999)            ; 1 MHz / 1000 = 1 ms
    movwf T2PR,1

    bsf T2CON,7,1             ; TMR2ON

    bcf PIR4,1,1
    bsf IPR4,1,1              ; haute priority
    bsf PIE4,1,1              ; activer

; TIMER0 = 10.24 ms — basse priorité
    movlw 0b10000000
    movwf T0CON0,1

    movlw 0b01000111          ; Fosc/4 / 256
    movwf T0CON1,1

ReloadTMR0:
    movlw 0xFD
    movwf TMR0H,1
    movlw 0x80
    movwf TMR0L,1

    bcf PIR0,5,1
    bcf IPR0,5,1              ; basse prio
    bsf PIE0,5,1

; Routines d'interruption ==================================================================
    bsf RCON,7,1              ; IPEN = 1
    bsf INTCON,6,1            ; pour PEIE
    bsf INTCON,7,1            ; pour GIE

loop:
    goto loop                 ; programme vide

High_ISR:
    btfss PIR4,1,1
    retfie

    bcf PIR4,1,1

    incf ChenillardCount,f,1
    movlw 125
    cpfseq ChenillardCount
    retfie                    ; <125 -> sortir de l'interruption

    clrf ChenillardCount

    ; ----- rotation rapide -----
    rlncf LedMask,f,1
    movf LedMask,w,1          ; Si rotation passe par zéro :
    bnz write_leds
    movlw 0x01
    movwf LedMask

write_leds:
    movf LedMask,w,1
    movwf LATB,1

    retfie

Low_ISR:
    btfss PIR0,5,1
    retfie

    bcf PIR0,5,1
    goto ReloadTMR0           ; recharge TMR0 immédiatement

ISR0_continue:
    incf LDM1Count,f,1
    movlw 125
    cpfseq LDM1Count
    retfie

    clrf LDM1Count
    btg LATC,6,1              ; désactive LDM1

    retfie

end
