PROCESSOR 18F25K40
#include <xc.inc>
    
; LED_MATRIX est connectée au port RB5
    
; Configuration ================================================================
config FEXTOSC = OFF
config RSTOSC = HFINTOSC_64MHZ
config WDTE = OFF
    
; Variables RAM ================================================================
PSECT udata_acs
 
; Code programme ===============================================================
PSECT code, abs
 
; Vecteur de reset =============================================================
org 0x000
    goto init
    
; Vecteur d'interruption haute priorité ========================================
org 0x008
    retfie
    
; Vecteur d'interruption basse priorité ========================================
org 0x018
    retfie
    
; Programme principal ==========================================================
org 0x100
    
; Initialisation ===============================================================
init:
    ; Désactivation des entrées analogiques
    banksel ANSELB
    clrf ANSELB     ; PORTB en mode digital
    
    ; Configuration RB5 en sortie
    banksel TRISB
    bcf TRISB, 5, 1         ; RB5 en sortie
    
    ; Éteindre LED_MATRIX au départ
    banksel LATB
    bcf LATB, 5, 1          ; LED_MATRIX éteinte
    
    ; Configuration du Timer2 pour 10 µs:
    
    ; Fosc = 64 MHz, Fosc/4 = 16 MHz
    ; Pour 10 microsec : 16 MHz * 10 microsec = 160 cycles
    
    ; PR2 = 160 - 1 = 159 = 0x9F
    
    banksel T2CLKCON
    movlw 0b00000001        ; Clock = Fosc/4
    movwf T2CLKCON, 1
    
    banksel T2PR
    movlw 159               ; PR2 = 159 pour période de 10 microsec
    movwf T2PR, 1
    
    banksel T2CON
    movlw 0b10000000        ; TMR2ON=1, prescaler 1:1, postscaler 1:1
    movwf T2CON, 1
    
    ; Effacer le flag TMR2IF (dans PIR4, bit 1)
    banksel PIR4
    bcf PIR4, 1, 1          ; TMR2IF effacé
    
    banksel 0               ; Retour à bank 0
    
; Boucle principale ============================================================
loop:
    ; Scruter le flag TMR2IF
    banksel PIR4
    btfss PIR4, 1, 1        ; Tester TMR2IF (bit 1 de PIR4)
    goto loop               ; Si pas d'overflow, continue à scruter
    
    ; Timer2 a expiré
    bcf PIR4, 1, 1          ; Effacer le flag TMR2IF
    
    ; Inverser l'état de LED_MATRIX (RB5)
    banksel LATB
    btg LATB, 5, 1          ; Toggle RB5
    
    banksel 0
    goto loop
    
; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
    
end
