PROCESSOR 18F25K40
#include <xc.inc>
    
; LED LDM1 est connectée au port RB4
    
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
    ; Désactiver les entrées analogiques
    banksel ANSELB
    clrf ANSELB, 1          ; PORTB en mode digital
    
    ; Configurer RB4 (LDM1) en sortie
    banksel TRISB
    bcf TRISB, 4, 1         ; RB4 en sortie
    
    ; Allumer la LED au départ
    banksel LATB
    bsf LATB, 4, 1          ; LED allumée
    
    ; Configuration du Timer0
    ; Fosc = 64 MHz, Fosc/4 = 16 MHz
    ; Pour 0.5s : 16 000 000 / 2 = 8 000 000 cycles
    ; Avec prescaler 1:256 : 8 000 000 / 256 = 31 250 cycles
    ; TMR0 est 16 bits, on charge : 65536 - 31250 = 34286 = 0x85EE
    
    banksel T0CON1
    movlw 0b01001000        ; Clock source = Fosc/4, prescaler 1:256
    movwf T0CON1, 1
    
    banksel T0CON0
    movlw 0b10010000        ; T0EN=1 (enable), 16-bit mode
    movwf T0CON0, 1
    
    ; Charger la valeur initiale du Timer0
    banksel TMR0H
    movlw HIGH(34286)       ; Partie haute
    movwf TMR0H, 1
    movlw LOW(34286)        ; Partie basse
    movwf TMR0L, 1
    
    ; Effacer le flag d'overflow (TMR0IF dans PIR0, bit 5)
    banksel PIR0
    bcf PIR0, 5, 1          ; TMR0IF est le bit 5 de PIR0
    
    banksel 0               ; Retour à bank 0
    
loop:
    ; Scruter le flag TMR0IF
    banksel PIR0
    btfss PIR0, 5, 1        ; Tester TMR0IF (bit 5 de PIR0)
    goto loop               ; Si pas d'overflow, continuer à scruter
    
    ; Timer0 a expiré
    bcf PIR0, 5, 1          ; Effacer le flag TMR0IF
    
    ; Recharger le Timer0
    banksel TMR0H
    movlw HIGH(34286)
    movwf TMR0H, 1
    movlw LOW(34286)
    movwf TMR0L, 1
    
    ; Inverser l'état de la LED LDM1 (RB4)
    banksel LATB
    btg LATB, 4, 1          ; Toggle RB4
    
    banksel 0
    goto loop
    
; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
    
end
