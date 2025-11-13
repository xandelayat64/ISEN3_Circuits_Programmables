PROCESSOR 18F25K40
#include <xc.inc>

; Configuration ================================================================
config FEXTOSC = OFF           ; Pas de source d'horloge externe
config RSTOSC = HFINTOSC_64MHZ ; Horloge interne de 64 MHz
config WDTE = OFF              ; Desactiver le watchdog	timer

;la LED LD0 est reliée au port RC0
;les LED LDx sont reliées aux ports RCx
	
PSECT   code, abs
   
; Vecteur de reset =============================================================
org     0x000
goto init 
   
; Vecteur d'interruption haute priorite ========================================
org     0x008
goto High_ISR 

; Vecteur d'interruption basse priorite ========================================
org     0x018
goto Low_ISR 

; Programme principal ==========================================================
org 0x100   

init:
    ; Initialisation    
    bcf TRISC, 0  ;le port RC0 est une sortie
    bsf LATC, 0   ;mise à l'état haut du port RC0
    goto loop

loop:
    ; Boucle infinie
    goto loop

; Routines d'interruption ======================================================    
High_ISR:
    retfie
    
Low_ISR:  
    retfie
     
end