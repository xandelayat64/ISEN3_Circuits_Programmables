PROCESSOR 18F25K40
#include <xc.inc>

;la LED LD0 est reliée au port RC0
;les LED LDx sont reliées aux ports RCx

; Configuration ================================================================
config FEXTOSC = OFF
config RSTOSC = HFINTOSC_64MHZ
config WDTE = OFF

; Variables RAM ================================================================

;réserver octets pour les variables RAM
PSECT udata_acs
COUNTL:     ds 1
COUNTH:     ds 1
LEDVAL:     ds 1

; Code programme
PSECT   code, abs

; Vecteur de reset =============================================================
org 0x000
goto init

; Vecteur d'interruption haute priorite ========================================
org 0x008
goto High_ISR

; Vecteur d'interruption basse priorite ========================================
org 0x018
goto Low_ISR

; Programme principal ==========================================================
org 0x100

; Initialisation
init:


    ; PORT C -> sortie LEDs
    movlw 0x00
    movwf TRISC, 0        ; LEDs en sortie

    movlw 0x01
    movwf LEDVAL, 0      ; LED0 allumée

    ; PORT B -> boutons en entrée
    movlw 0xFF
    movwf TRISB, 0       ; RB0–RB7 en entrée

    goto loop

; Boucle principale
loop:

    ;timer : boucle ~65536 itérations
    clrf COUNTL, 0
    clrf COUNTH, 0

DelayLoop:
    incf COUNTL, F, a
    bnz  DelayLoop
    incf COUNTH, F, a
    bnz  DelayLoop

    ; Lire RB0 et RB1
    movf PORTB, W, a
    andlw 0b00000011    ; isoler B0 et B1

    ; RB0 = 0 -> sens avant (0 à 7)
    btfss PORTB, 0, 0         ; skip si RB0 = 1 (relaché)
    goto ZeroToSeven          ; RB0 = 0 -> appuyé

    ; RB1 = 0 -> sens arrière (7 à 0)
    btfss PORTB, 1, 0
    goto SevenToZero

    goto loop    ; aucun bouton

; Chenillard sens avant
ZeroToSeven:
    rlcf LEDVAL, F, a     ; décalage à gauche
    movf LEDVAL, W, a
    bnz SA_OK
    movlw 0x01
    movwf LEDVAL, 0
SA_OK:
    goto MajLED

; Chenillard sens arrière
SevenToZero:
    rrncf LEDVAL, 1, 0     ; décalage à droite
    movf LEDVAL, W, a
    bnz SR_OK
    movlw 0x80
    movwf LEDVAL, 0
SR_OK:
    goto MajLED

; Mise à jour LEDs
MajLED:
    movf LEDVAL, W, a
    movwf LATC, a
    goto loop

; Routines d'interruption ======================================================  
High_ISR:
    retfie

Low_ISR:
    retfie

end
